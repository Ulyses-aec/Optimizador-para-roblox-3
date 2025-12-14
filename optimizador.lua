local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN
local settings = {
    PlasticMode = true,
    PlasticColor = Color3.fromRGB(220, 220, 220),
    MaxTextureSize = 32,
    PlasticSaturation = 0.3,
    PlasticBrightness = 1.2,
    PlasticReflectance = 0.15,
    AmbientColor = Color3.fromRGB(180, 180, 180),
    NoShadows = true,
    ForcePlasticMaterial = true,
    KeepSky = true,
    PreserveCharacterFaces = true,
    UseSmoothTransition = false,
    InstantPlastic = true
}

-- ========================================
-- CONTADOR DE FPS
-- ========================================
local function createFPSCounter()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSCounterGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Name = "FPSFrame"
    frame.Size = UDim2.new(0, 100, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local fpsText = Instance.new("TextLabel")
    fpsText.Name = "FPSText"
    fpsText.Size = UDim2.new(1, 0, 1, 0)
    fpsText.Position = UDim2.new(0, 0, 0, 0)
    fpsText.BackgroundTransparency = 1
    fpsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsText.TextStrokeTransparency = 0.5
    fpsText.Text = "FPS: 60"
    fpsText.Font = Enum.Font.SourceSansBold
    fpsText.TextSize = 18
    fpsText.TextXAlignment = Enum.TextXAlignment.Center
    fpsText.TextYAlignment = Enum.TextYAlignment.Center
    fpsText.Parent = frame
    
    local lastTime = tick()
    local frameCount = 0
    local fps = 60
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 0.5 then
            fps = math.floor(frameCount / (currentTime - lastTime))
            frameCount = 0
            lastTime = currentTime
            
            -- Actualizar texto
            fpsText.Text = "FPS: " .. fps
            
            -- Cambiar color según FPS
            if fps >= 50 then
                fpsText.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Verde
            elseif fps >= 30 then
                fpsText.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Amarillo
            else
                fpsText.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Rojo
            end
        end
    end)
    
    -- Hacerlo arrastrable
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local startPos = Vector2.new(0, 0)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    
    return screenGui
end

-- Crear contador de FPS
local fpsCounter = createFPSCounter()

-- ========================================
-- FUNCIÓN DE SEGURIDAD PARA UI
-- ========================================
local function isSafeToModify(obj)
    local current = obj
    while current do
        if current == CoreGui or 
           current == StarterGui or 
           current:IsA("PlayerGui") or
           current:IsA("ScreenGui") or
           current:IsA("SurfaceGui") or
           current:IsA("BillboardGui") or
           current:IsA("GuiObject") then
            return false
        end
        current = current.Parent
    end
    return true
end

-- ========================================
-- EFECTO PLÁSTICO
-- ========================================
local function applyPlasticEffect(obj, originalColor)
    if not obj:IsA("BasePart") then return end
    if not isSafeToModify(obj) then return end
    
    local success, result = pcall(function()
        if settings.PlasticMode then
            local r, g, b = originalColor.R, originalColor.G, originalColor.B
            local intensity = (r + g + b) / 3
            r = r * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            g = g * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            b = b * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            
            r = math.min(1, r * settings.PlasticBrightness)
            g = math.min(1, g * settings.PlasticBrightness)
            b = math.min(1, b * settings.PlasticBrightness)
            
            r = (r + settings.PlasticColor.R) / 2
            g = (g + settings.PlasticColor.G) / 2
            b = (b + settings.PlasticColor.B) / 2
            
            obj.Color = Color3.new(r, g, b)
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = settings.PlasticReflectance
            obj.CastShadow = settings.NoShadows == false
            
            if obj:IsA("MeshPart") then
                obj.TextureID = "rbxasset://textures/SurfaceTexture.png"
            end
            
            if settings.ForcePlasticMaterial then
                if obj.Material == Enum.Material.Neon or 
                   obj.Material == Enum.Material.Glass or
                   obj.Material == Enum.Material.Foil then
                    obj.Material = Enum.Material.Plastic
                end
            end
        end
    end)
end

-- ========================================
-- PROCESAMIENTO PRINCIPAL
-- ========================================
local processed = 0
local batchCounter = 0

for _, obj in ipairs(workspace:GetDescendants()) do
    if not isSafeToModify(obj) then continue end
    
    local success = pcall(function()
        if obj:IsA("Texture") then
            obj.Transparency = 1
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                applyPlasticEffect(part, part.Color)
            end
            processed = processed + 1
        elseif obj:IsA("Decal") then
            if not (settings.PreserveCharacterFaces and 
                   (obj.Name == "face" or string.find(obj.Name:lower(), "face"))) then
                obj:Destroy()
                processed = processed + 1
            end
        elseif obj:IsA("BasePart") then
            applyPlasticEffect(obj, obj.Color)
            processed = processed + 1
        elseif obj:IsA("MeshPart") then
            obj.TextureID = "rbxasset://textures/SurfaceTexture.png"
            applyPlasticEffect(obj, obj.Color)
            processed = processed + 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj:Destroy()
            processed = processed + 1
        end
    end)
    
    batchCounter = batchCounter + 1
    if batchCounter >= 100 then
        batchCounter = 0
        wait(0.01)
    end
end

-- ========================================
-- ILUMINACIÓN
-- ========================================
pcall(function()
    if settings.KeepSky then
        local sky = Lighting:FindFirstChild("Sky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = Lighting
        end
        
        sky.SkyboxBk = "rbxasset://sky/sky512_bk.tex"
        sky.SkyboxDn = "rbxasset://sky/sky512_dn.tex"
        sky.SkyboxFt = "rbxasset://sky/sky512_ft.tex"
        sky.SkyboxLf = "rbxasset://sky/sky512_lf.tex"
        sky.SkyboxRt = "rbxasset://sky/sky512_rt.tex"
        sky.SkyboxUp = "rbxasset://sky/sky512_up.tex"
    end
    
    Lighting.Brightness = 4
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    Lighting.ExposureCompensation = 0.7
    
    local effects = {"BloomEffect", "ColorCorrectionEffect", "SunRaysEffect", "Atmosphere"}
    for _, effectName in ipairs(effects) do
        local effect = Lighting:FindFirstChild(effectName)
        if effect then effect:Destroy() end
    end
end)

-- ========================================
-- CONFIGURACIÓN GRÁFICA
-- ========================================
pcall(function()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.EagerBulkExecution = true
end)

-- ========================================
-- LISTENER PARA NUEVOS OBJETOS
-- ========================================
workspace.DescendantAdded:Connect(function(obj)
    wait(1)
    if isSafeToModify(obj) then
        pcall(function()
            if obj:IsA("BasePart") then
                applyPlasticEffect(obj, obj.Color)
            end
        end)
    end
end)

-- ========================================
-- FUNCIÓN PARA TOGGLE FPS COUNTER
-- ========================================
local function toggleFPSCounter()
    if fpsCounter then
        fpsCounter.Enabled = not fpsCounter.Enabled
    end
end

-- Hacerla accesible globalmente
_G.ToggleFPS = toggleFPSCounter

-- ========================================
-- INFORMACIÓN EN CONSOLA
-- ========================================
print("✅ Gráficos plásticos activados")
print("📊 Contador de FPS creado")
print("🎮 Controles protegidos")
print("🔄 Usa _G.ToggleFPS() para mostrar/ocultar FPS")
