local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local ShitMode = {
    enabled = true,
    color = Color3.new(0.5, 0.5, 0.5),
    material = Enum.Material.SmoothPlastic,
    noShadows = true,
    noReflections = true,
    noTextures = true,
    noEffects = true,
    noLights = true,
    noSounds = false,  -- <- CAMBIADO A FALSE (SONIDOS ACTIVADOS)
    lowPhysics = true,
    maxFPS = 144,
    destroyEverything = true
}

-- CONTADOR FPS LIGERO
local fpsText = nil
local function initFPS()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShitFPS"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 40, 0, 20)
    text.Position = UDim2.new(0, 2, 0, 2)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Text = "0"
    text.Font = Enum.Font.SourceSans
    text.TextSize = 16
    text.Parent = gui
    
    fpsText = text
    
    local frames = 0
    local last = tick()
    
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        
        if now - last >= 0.5 then
            local fps = math.floor(frames / (now - last))
            frames = 0
            last = now
            fpsText.Text = tostring(fps)
        end
    end)
end

-- PROCESAMIENTO POR LOTES (ASYNC)
local function processInBatches(objects, processFunc, batchSize)
    batchSize = batchSize or 50
    
    spawn(function()
        for i = 1, #objects, batchSize do
            local batchEnd = math.min(i + batchSize - 1, #objects)
            
            for j = i, batchEnd do
                local obj = objects[j]
                pcall(processFunc, obj)
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
end

local function applyShitVisual(obj)
    if not obj:IsA("BasePart") then return end
    
    obj.Color = ShitMode.color
    obj.Material = ShitMode.material
    obj.Reflectance = 0
    obj.Transparency = 0
    obj.CastShadow = false
    
    if obj:IsA("MeshPart") then
        obj.TextureID = ""
    end
end

local function hideHitEffect(obj)
    if not obj:IsA("BasePart") then return end
    
    local name = obj.Name:lower()
    if name:find("hit") or 
       name:find("damage") or 
       name:find("attack") or
       name:find("effect") or
       name:find("box") or
       name:find("impact") or
       name:find("blast") then
        obj.Transparency = 1
    end
end

local function destroyEffect(obj)
    -- NO DESTRUIR SONIDOS
    if obj:IsA("ParticleEmitter") or 
       obj:IsA("Fire") or obj:IsA("Smoke") or
       obj:IsA("Beam") or obj:IsA("Trail") or
       obj:IsA("Sparkles") or obj:IsA("Explosion") or
       obj:IsA("PointLight") or 
       obj:IsA("SurfaceLight") or 
       obj:IsA("SpotLight") or
       obj:IsA("Texture") or 
       obj:IsA("Decal") then
        obj:Destroy()
    end
    -- LOS SONIDOS NO SE DESTRUYEN
end

-- CONFIGURACIONES RÁPIDAS
local function quickSetup()
    Lighting.Brightness = 1
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    
    local toRemove = {}
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") then
            table.insert(toRemove, child)
        end
    end
    
    for _, child in ipairs(toRemove) do
        child:Destroy()
    end
    
    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Physics.AllowSleep = true
    end)
end

-- INICIALIZACIÓN OPTIMIZADA
local function optimizedInit()
    initFPS()
    quickSetup()
    
    local allObjects = workspace:GetDescendants()
    local parts = {}
    local effects = {}
    
    for _, obj in ipairs(allObjects) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        else
            if not obj:IsA("Sound") then  -- Excluir sonidos
                table.insert(effects, obj)
            end
        end
    end
    
    spawn(function()
        processInBatches(effects, destroyEffect, 100)
        
        processInBatches(parts, function(obj)
            applyShitVisual(obj)
            hideHitEffect(obj)
        end, 200)
        
        if fpsText then
            fpsText.TextColor3 = Color3.new(0, 1, 0)
        end
    end)
    
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            spawn(function()
                applyShitVisual(obj)
                hideHitEffect(obj)
            end)
        elseif not obj:IsA("Sound") then  -- Sonidos permitidos
            spawn(function()
                destroyEffect(obj)
            end)
        end
    end)
end

optimizedInit()

_G.ToggleShitMode = function()
    ShitMode.enabled = not ShitMode.enabled
end

_G.BoostFPS = function()
    spawn(function()
        local parts = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
        end
        processInBatches(parts, applyShitVisual, 200)
    end)
end

_G.HideHitEffects = function()
    spawn(function()
        local parts = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
        end
        processInBatches(parts, hideHitEffect, 200)
    end)
end
