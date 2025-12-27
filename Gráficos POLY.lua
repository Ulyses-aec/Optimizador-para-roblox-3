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
    lowPhysics = true
}

local fpsHistory = {}
local minFPS = 999
local lastFPSDrop = 0
local fpsText = nil

local function initFPS()
    local gui = Instance.new("ScreenGui")
    gui.Name = "StableFPS"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 60, 0, 25)
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
            local currentFPS = math.floor(frames / (now - last))
            frames = 0
            last = now
            
            table.insert(fpsHistory, currentFPS)
            if #fpsHistory > 10 then table.remove(fpsHistory, 1) end
            
            minFPS = math.min(minFPS, currentFPS)
            
            local avgFPS = 0
            for _, fps in ipairs(fpsHistory) do
                avgFPS = avgFPS + fps
            end
            avgFPS = avgFPS / #fpsHistory
            
            if currentFPS < (avgFPS * 0.7) then
                lastFPSDrop = now
                fpsText.TextColor3 = Color3.new(1, 0.5, 0)
                fpsText.Text = currentFPS .. "⚠️"
            else
                if currentFPS >= 100 then
                    fpsText.TextColor3 = Color3.new(0, 1, 0)
                elseif currentFPS >= 60 then
                    fpsText.TextColor3 = Color3.new(1, 1, 0)
                elseif currentFPS >= 30 then
                    fpsText.TextColor3 = Color3.new(1, 0.5, 0)
                else
                    fpsText.TextColor3 = Color3.new(1, 0, 0)
                end
                fpsText.Text = currentFPS .. ""
            end
            
            if now % 10 < 0.5 then
                fpsText.Text = currentFPS .. "|" .. minFPS
            end
        end
    end)
    
    return text
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
    if name:find("hit") or name:find("damage") or name:find("attack") then
        obj.Transparency = 1
    end
end

local function destroyEffect(obj)
    if obj:IsA("ParticleEmitter") then
        obj:Destroy()
    elseif obj:IsA("Fire") or obj:IsA("Smoke") then
        obj:Destroy()
    end
end

local function fastOptimization()
    local startTime = tick()
    local count = 0
    
    Lighting.Brightness = 1
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Sky") then
            child:Destroy()
        end
    end
    
    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Physics.AllowSleep = true
    end)
    
    local objects = workspace:GetDescendants()
    for i = 1, #objects do
        local obj = objects[i]
        
        if obj:IsA("BasePart") then
            applyShitVisual(obj)
            hideHitEffect(obj)
            count = count + 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            destroyEffect(obj)
            count = count + 1
        end
        
        if i % 500 == 0 then
            task.wait(0.001)
        end
    end
    
    return count
end

local function backgroundOptimizations()
    spawn(function()
        wait(3)
        
        local meshCount = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("MeshPart") then
                obj.LODX = Enum.LevelOfDetail.Low
                obj.LODY = Enum.LevelOfDetail.Low
                meshCount = meshCount + 1
                
                if meshCount % 100 == 0 then
                    wait(0.01)
                end
            end
        end
        
        pcall(function()
            settings().Rendering.FramerateManagerMode = Enum.RenderFramerateManagerMode.Automatic
            if settings().Rendering.EnableStreaming ~= nil then
                settings().Rendering.EnableStreaming = false
            end
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        end)
    end)
end

local function setupAntiStutter()
    local processingQueue = {}
    local isProcessing = false
    
    local function processQueue()
        if isProcessing or #processingQueue == 0 then return end
        isProcessing = true
        
        spawn(function()
            while #processingQueue > 0 do
                local obj = table.remove(processingQueue, 1)
                
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then
                        applyShitVisual(obj)
                        hideHitEffect(obj)
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                        destroyEffect(obj)
                    end
                end
                
                if #processingQueue % 10 == 0 then
                    RunService.RenderStepped:Wait()
                end
            end
            
            isProcessing = false
        end)
    end
    
    workspace.DescendantAdded:Connect(function(obj)
        table.insert(processingQueue, obj)
        processQueue()
    end)
end

local function setupSmartGC()
    spawn(function()
        while true do
            wait(30)
            
            local currentFPS = tonumber(string.match(fpsText.Text or "60", "%d+")) or 60
            if currentFPS < 45 then
                pcall(function()
                    if game:GetService("Stats") then
                        game:GetService("Stats"):RequestGC()
                    end
                end)
            end
        end
    end)
end

initFPS()
local processed = fastOptimization()
backgroundOptimizations()
setupAntiStutter()
setupSmartGC()

_G.ToggleShitMode = function()
    ShitMode.enabled = not ShitMode.enabled
end

_G.BoostFPS = function()
    spawn(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                applyShitVisual(obj)
                count = count + 1
                
                if count % 200 == 0 then
                    wait(0.001)
                end
            end
        end
    end)
end

_G.ForceStable = function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj:Destroy()
        end
    end
    
    pcall(function()
        settings().Rendering.QualityLevel = 1
    end)
end

_G.GetFPSStats = function()
    return {
        current = tonumber(string.match(fpsText.Text or "0", "%d+")) or 0,
        min = minFPS,
        lastDrop = lastFPSDrop > 0 and tick() - lastFPSDrop or 0
    }
end
