-- Продвинутый скрипт-чит для своего режима
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local Config = {
    WalkSpeed = 50,       -- Скорость бега (обычная 16)
    JumpPower = 100,      -- Высота прыжка (обычная 50)
    AimbotEnabled = true, -- Включить Аим?
    EspEnabled = true     -- Включить ВХ?
}

-- 1. СКОРОСТЬ И ПРЫЖОК (Обновляется при возрождении)
local function modifyCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.JumpPower = Config.JumpPower
    
    -- Исправление для новых версий (если прыжок не работает)
    humanoid.UseJumpPower = true 
end

if LocalPlayer.Character then modifyCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(modifyCharacter)

-- 2. ESP (Подсветка игроков через стены)
local function createESP(player)
    if player == LocalPlayer then return end
    
    local function applyHighlight(character)
        if not character:FindFirstChild("EspHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EspHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный цвет заливки
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белая обводка
            highlight.FillTransparency = 0.5
            highlight.Parent = character
        end
    end
    
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

if Config.EspEnabled then
    for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(createESP)
end

-- 3. ПРОСТОЙ AIMBOT (Наведение камеры на ближайшего игрока)
game:GetService("RunService").RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Проверяем, жив ли игрок
            if player.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                
                if onScreen then
                    -- Считаем расстояние от прицела (центра экрана) до игрока
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance and distance < 400 then -- 400 это радиус (FOV)
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    -- Плавно наводим камеру на цель
    if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
    end
end)

print("Скрипт успешно активирован!")
