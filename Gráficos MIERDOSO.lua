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
    noSounds = true,
    lowPhysics = true,
    maxFPS = 144,
    destroyEverything = true
}

local function createShitFPS()
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
    
    local frames = 0
    local last = tick()
    local fps = 0
    
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        
        if now - last >= 0.2 then
            fps = math.floor(frames / (now - last))
            frames = 0
            last = now
            text.Text = tostring(fps)
        end
    end)
    
    return gui
end

local function applyShitVisual(obj)
    if not obj:IsA("BasePart") then return end
    
    pcall(function()
        obj.Color = ShitMode.color
        obj.Material = ShitMode.material
        obj.Reflectance = 0
        obj.Transparency = 0
        obj.CastShadow = false
        
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end)
end

local function destroyAllBeauty()
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or 
               obj:IsA("Fire") or obj:IsA("Smoke") or
               obj:IsA("Beam") or obj:IsA("Trail") or
               obj:IsA("Sparkles") or obj:IsA("Explosion") or
               obj:IsA("PointLight") or 
               obj:IsA("SurfaceLight") or 
               obj:IsA("SpotLight") or
               obj:IsA("Sound") or
               obj:IsA("Texture") or 
               obj:IsA("Decal") then
                obj:Destroy()
            end
        end)
    end
end

local function removeHitBoxes()
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                if obj.Name:lower():find("hit") or
                   obj.Name:lower():find("damage") or
                   obj.Name:lower():find("hitbox") or
                   obj.Name:lower():find("attack") then
                    obj.Transparency = 1
                end
            end
        end)
    end
end

local function extremePerformanceBoost()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Rendering.EagerBulkExecution = true
        settings().Rendering.EnableFRM = true
        settings().Rendering.FramerateManagerMode = 0
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = 2
        
        if settings().Rendering.EnableStreaming then
            settings().Rendering.EnableStreaming = false
        end
    end)
end

local function setupShitLighting()
    pcall(function()
        Lighting.Brightness = 1
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or 
               child:IsA("Atmosphere") or
               child:IsA("Sky") then
                child:Destroy()
            end
        end
    end)
end

local function setupMaxPerformance()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Physics.AllowSleep = true
        
        if ShitMode.lowPhysics then
            settings().Physics.PhysicsEnvironmentalThrottle = 2
        end
    end)
end

local function limitFPS()
    if ShitMode.maxFPS > 0 then
        local targetTime = 1 / ShitMode.maxFPS
        local lastTime = tick()
        
        RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            local elapsed = currentTime - lastTime
            
            if elapsed < targetTime then
                wait(targetTime - elapsed)
            end
            
            lastTime = tick()
        end)
    end
end

local function preventNewShit()
    workspace.DescendantAdded:Connect(function(obj)
        wait(0.01)
        
        pcall(function()
            if obj:IsA("BasePart") then
                applyShitVisual(obj)
                
                if obj.Name:lower():find("hit") or
                   obj.Name:lower():find("damage") or
                   obj.Name:lower():find("hitbox") or
                   obj.Name:lower():find("attack") then
                    obj.Transparency = 1
                end
            elseif obj:IsA("ParticleEmitter") or 
                   obj:IsA("Fire") or 
                   obj:IsA("PointLight") or
                   obj:IsA("Sound") then
                obj:Destroy()
            end
        end)
    end)
end

local function forceGC()
    spawn(function()
        while true do
            wait(10)
            if game:GetService("Stats") then
                pcall(function()
                    game:GetService("Stats"):RequestGC()
                end)
            end
        end
    end)
end

local function optimizeMeshes()
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("MeshPart") then
                obj.LODX = Enum.LevelOfDetail.Lowest
                obj.LODY = Enum.LevelOfDetail.Lowest
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end
        end)
    end
end

local fpsCounter = createShitFPS()

if ShitMode.destroyEverything then
    destroyAllBeauty()
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        applyShitVisual(obj)
    end
end

removeHitBoxes()
setupShitLighting()
setupMaxPerformance()
extremePerformanceBoost()
optimizeMeshes()
limitFPS()
preventNewShit()
forceGC()

_G.ToggleShitMode = function()
    ShitMode.enabled = not ShitMode.enabled
end

_G.BoostFPS = function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            applyShitVisual(obj)
        end
    end
end

_G.RemoveHitBoxes = function()
    removeHitBoxes()
end
