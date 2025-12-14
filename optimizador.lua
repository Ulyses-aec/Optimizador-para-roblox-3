local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- CONFIGURACIÓN MÁS FUERTE PARA PLÁSTICO
local settings = {
    -- TEXTURAS PLÁSTICAS (MÁS FUERTE)
    PlasticMode = true,
    PlasticColor = Color3.fromRGB(220, 220, 220),  -- Más claro, más plástico
    MaxTextureSize = 32,  -- Más pequeño para más FPS
    
    -- EFECTO PLÁSTICO FUERTE
    PlasticSaturation = 0.3,  -- Menos saturación (más plástico)
    PlasticBrightness = 1.2,  -- Más brillo
    PlasticReflectance = 0.15,  -- Más reflejo plástico
    
    -- ILUMINACIÓN
    BrightLighting = true,
    AmbientColor = Color3.fromRGB(180, 180, 180),  -- Más brillante
    
    -- EFECTOS
    NoShadows = true,
    NoParticles = true,
    NoReflections = false,  -- Permitir reflejos para plástico
    
    -- MATERIALES
    ForcePlasticMaterial = true,
    KeepWater = false,
    
    -- CORE
    KeepSky = true,
    PreserveCharacterFaces = true,
    
    -- INTERPOLACIÓN MÁS RÁPIDA
    UseSmoothTransition = false,  -- DESACTIVADO para efecto plástico fuerte
    InstantPlastic = true  -- Cambio instantáneo para efecto plástico claro
}

-- FUNCIÓN MEJORADA PARA EFECTO PLÁSTICO FUERTE
function applyPlasticEffect(obj, originalColor)
    if not obj:IsA("BasePart") then return end
    
    pcall(function()
        if settings.PlasticMode then
            -- CONVERSIÓN MÁS FUERTE A PLÁSTICO
            local r, g, b = originalColor.R, originalColor.G, originalColor.B
            
            -- 1. Reducir saturación drásticamente
            local intensity = (r + g + b) / 3
            r = r * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            g = g * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            b = b * (1 - settings.PlasticSaturation) + intensity * settings.PlasticSaturation
            
            -- 2. Aumentar brillo
            r = math.min(1, r * settings.PlasticBrightness)
            g = math.min(1, g * settings.PlasticBrightness)
            b = math.min(1, b * settings.PlasticBrightness)
            
            -- 3. Aplicar tono plástico base
            r = (r + settings.PlasticColor.R) / 2
            g = (g + settings.PlasticColor.G) / 2
            b = (b + settings.PlasticColor.B) / 2
            
            -- APLICACIÓN INSTANTÁNEA (sin interpolación para efecto fuerte)
            obj.Color = Color3.new(r, g, b)
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = settings.PlasticReflectance
            obj.CastShadow = settings.NoShadows == false
            
            -- TEXTURA PLÁSTICA (si es MeshPart)
            if obj:IsA("MeshPart") then
                obj.TextureID = "rbxasset://textures/SurfaceTexture.png"  -- Textura plástica de Roblox
            end
            
            -- FORZAR PROPIEDADES PLÁSTICAS
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

-- FUNCIÓN ESPECIAL PARA TEXTURAS (PLÁSTICO FUERTE)
function plasticizeTexturesStrong()
    print("🎨 APLICANDO EFECTO PLÁSTICO FUERTE...")
    
    local processed = 0
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Texture") or obj:IsA("Decal") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local originalColor = part.Color
                    
                    -- ELIMINAR TEXTURAS (no reducir, eliminar para efecto plástico puro)
                    if settings.PlasticMode then
                        if obj:IsA("Texture") then
                            -- En lugar de reducir tamaño, eliminar textura
                            obj.Transparency = 1  -- Hacer invisible
                            processed = processed + 1
                        elseif obj:IsA("Decal") then
                            -- Eliminar decals completamente
                            if not (settings.PreserveCharacterFaces and 
                                   (obj.Name == "face" or string.find(obj.Name:lower(), "face"))) then
                                obj:Destroy()
                                processed = processed + 1
                            end
                        end
                    end
                    
                    -- APLICAR PLÁSTICO FUERTE A LA PARTE
                    applyPlasticEffect(part, originalColor)
                end
            elseif obj:IsA("BasePart") then
                -- PLÁSTICO DIRECTO A PARTES
                applyPlasticEffect(obj, obj.Color)
                processed = processed + 1
            elseif obj:IsA("MeshPart") then
                -- MESHPART: Textura plástica estándar
                obj.TextureID = "rbxasset://textures/SurfaceTexture.png"
                applyPlasticEffect(obj, obj.Color)
                processed = processed + 1
            end
        end)
    end
    
    print("✅ Objetos plastificados (fuerte): " .. processed)
    return processed
end

-- CONFIGURACIÓN DE ILUMINACIÓN PARA PLÁSTICO
function setupPlasticLightingStrong()
    print("💡 CONFIGURANDO ILUMINACIÓN PARA PLÁSTICO FUERTE...")
    
    pcall(function()
        -- CIELO BRILLANTE
        local sky = Lighting:FindFirstChild("Sky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = Lighting
        end
        
        -- Skybox brillante
        sky.SkyboxBk = "rbxasset://sky/sky512_bk.tex"
        sky.SkyboxDn = "rbxasset://sky/sky512_dn.tex"
        sky.SkyboxFt = "rbxasset://sky/sky512_ft.tex"
        sky.SkyboxLf = "rbxasset://sky/sky512_lf.tex"
        sky.SkyboxRt = "rbxasset://sky/sky512_rt.tex"
        sky.SkyboxUp = "rbxasset://sky/sky512_up.tex"
        
        -- ILUMINACIÓN FUERTE Y PLANA (mejor para plástico)
        Lighting.Brightness = 4  -- Más brillante
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)  -- Blanco brillante
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.ExposureCompensation = 0.7  -- Más exposición
        
        -- ELIMINAR EFECTOS QUE AFECTAN COLORES
        local effects = {"BloomEffect", "ColorCorrectionEffect", "SunRaysEffect", "Atmosphere"}
        for _, effectName in ipairs(effects) do
            local effect = Lighting:FindFirstChild(effectName)
            if effect then effect:Destroy() end
        end
    end)
    
    print("✅ Iluminación plástica fuerte configurada")
end

-- FUNCIÓN PRINCIPAL CON PLÁSTICO FUERTE
function applyStrongPlasticOptimization()
    print("========================================")
    print("🛠️  OPTIMIZACIÓN PLÁSTICA FUERTE")
    print("🎯 Efecto plástico VISIBLE + Máximo FPS")
    print("========================================")
    
    -- 1. Iluminación brillante
    setupPlasticLightingStrong()
    
    -- 2. Aplicar plástico fuerte (instantáneo)
    local objects = plasticizeTexturesStrong()
    
    -- 3. Resultados
    print("========================================")
    print("✅ PLÁSTICO FUERTE APLICADO")
    print("🔧 Configuración activa:")
    print("   • Material: Plastic (fuerte)")
    print("   • Reflectancia: " .. settings.PlasticReflectance)
    print("   • Brillo: " .. settings.PlasticBrightness .. "x")
    print("   • Texturas: ELIMINADAS")
    print("   • Transiciones: INSTANTÁNEAS")
    print("========================================")
    
    return { plasticObjects = objects }
end

-- EJECUTAR INMEDIATAMENTE
local success, result = pcall(applyStrongPlasticOptimization)
if not success then
    warn("⚠️ Error: " .. tostring(result))
    pcall(function()
        Lighting.Brightness = 4
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    end)
end

print("🎮 PLÁSTICO FUERTE ACTIVADO - Todo se verá como plástico brillante")
