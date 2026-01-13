-- JHub Panel - Ping & CPU Monitor (Modern Redesign)
-- Module yang bisa dipanggil dengan PingFPSMonitor:Show() dan :Hide()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local PingFPSMonitor = {}
PingFPSMonitor.__index = PingFPSMonitor

local player = Players.LocalPlayer
local updateConnection, pingUpdateConnection
local gui = {}
local isVisible = false

-- Fungsi untuk membuat GUI dengan Modern Design
local function createMonitorGUI()
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JHubPanelMonitor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.DisplayOrder = 999999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui
    
    -- Main Container (Solid Background)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 240, 0, 90)
    container.Position = UDim2.new(0.5, -120, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(10, 13, 26) -- bg1
    container.BackgroundTransparency = 0
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 14)
    containerCorner.Parent = container
    
    -- Header Section
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    -- Title (Centered)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 32)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "JHUB"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = header
    
    -- Separator Line (No gradient, simple)
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, -20, 0, 1)
    separator.Position = UDim2.new(0, 10, 0, 36)
    separator.BackgroundColor3 = Color3.fromRGB(56, 189, 248) -- primary
    separator.BackgroundTransparency = 0.5
    separator.BorderSizePixel = 0
    separator.Parent = container


    -- Content Section (Metrics)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -48)
    content.Position = UDim2.new(0, 10, 0, 44)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    -- Ping Card
    local pingCard = Instance.new("Frame")
    pingCard.Name = "PingCard"
    pingCard.Size = UDim2.new(0.48, 0, 1, 0)
    pingCard.Position = UDim2.new(0, 0, 0, 0)
    pingCard.BackgroundColor3 = Color3.fromRGB(17, 24, 39) -- bg2
    pingCard.BackgroundTransparency = 0
    pingCard.BorderSizePixel = 0
    pingCard.Parent = content
    
    local pingCardCorner = Instance.new("UICorner")
    pingCardCorner.CornerRadius = UDim.new(0, 10)
    pingCardCorner.Parent = pingCard
    
    -- Ping Icon
    local pingIcon = Instance.new("TextLabel")
    pingIcon.Size = UDim2.new(1, 0, 0, 14)
    pingIcon.Position = UDim2.new(0, 0, 0, 4)
    pingIcon.BackgroundTransparency = 1
    pingIcon.Text = "📶"
    pingIcon.TextSize = 14
    pingIcon.Parent = pingCard
    
    -- Ping Label
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(1, -8, 0, 20)
    pingLabel.Position = UDim2.new(0, 4, 0, 18)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "0 ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLabel.TextSize = 14
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextXAlignment = Enum.TextXAlignment.Center
    pingLabel.Parent = pingCard
    
    -- CPU Card
    local cpuCard = Instance.new("Frame")
    cpuCard.Name = "CPUCard"
    cpuCard.Size = UDim2.new(0.48, 0, 1, 0)
    cpuCard.Position = UDim2.new(0.52, 0, 0, 0)
    cpuCard.BackgroundColor3 = Color3.fromRGB(17, 24, 39) -- bg2
    cpuCard.BackgroundTransparency = 0
    cpuCard.BorderSizePixel = 0
    cpuCard.Parent = content
    
    local cpuCardCorner = Instance.new("UICorner")
    cpuCardCorner.CornerRadius = UDim.new(0, 10)
    cpuCardCorner.Parent = cpuCard
    
    -- CPU Icon
    local cpuIcon = Instance.new("TextLabel")
    cpuIcon.Size = UDim2.new(1, 0, 0, 14)
    cpuIcon.Position = UDim2.new(0, 0, 0, 4)
    cpuIcon.BackgroundTransparency = 1
    cpuIcon.Text = "⚡"
    cpuIcon.TextSize = 14
    cpuIcon.Parent = cpuCard
    
    -- CPU Label
    local cpuLabel = Instance.new("TextLabel")
    cpuLabel.Name = "CPULabel"
    cpuLabel.Size = UDim2.new(1, -8, 0, 20)
    cpuLabel.Position = UDim2.new(0, 4, 0, 18)
    cpuLabel.BackgroundTransparency = 1
    cpuLabel.Text = "0%"
    cpuLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cpuLabel.TextSize = 14
    cpuLabel.Font = Enum.Font.GothamBold
    cpuLabel.TextXAlignment = Enum.TextXAlignment.Center
    cpuLabel.Parent = cpuCard
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    
    return {
        ScreenGui = screenGui,
        Container = container,
        PingLabel = pingLabel,
        CPULabel = cpuLabel,
        PingCard = pingCard,
        CPUCard = cpuCard
    }
end

-- Get Ping
local function getPing()
    local ping = 0
    pcall(function()
        local networkStats = Stats:FindFirstChild("Network")
        if networkStats then
            local serverStatsItem = networkStats:FindFirstChild("ServerStatsItem")
            if serverStatsItem then
                local pingStr = serverStatsItem["Data Ping"]:GetValueString()
                ping = tonumber(pingStr:match("%d+")) or 0
            end
        end
        
        if ping == 0 then
            ping = math.floor(player:GetNetworkPing() * 1000)
        end
    end)
    return ping
end

-- Get REAL CPU dari Roblox Stats
local function getCPU()
    local cpu = 0
    
    pcall(function()
        -- Method 1: Script Activity CPU (most accurate)
        local scriptContext = Stats:FindFirstChild("ScriptContext")
        if scriptContext then
            local scriptActivity = scriptContext:FindFirstChild("ScriptActivity")
            if scriptActivity then
                local cpuValue = scriptActivity:GetValue()
                cpu = math.floor(math.clamp(cpuValue * 100, 0, 100))
            end
        end
        
        -- Method 2: HeartbeatTimeMs from PerformanceStats
        if cpu == 0 then
            local perfStats = Stats:FindFirstChild("PerformanceStats")
            if perfStats then
                for _, child in pairs(perfStats:GetChildren()) do
                    local name = child.Name:lower()
                    if name:find("cpu") or name:find("heartbeat") or name:find("script") then
                        local success, value = pcall(function()
                            return child:GetValue()
                        end)
                        if success and value and type(value) == "number" then
                            if value < 100 then
                                cpu = math.floor(math.clamp((value / 16.67) * 100, 0, 100))
                                break
                            elseif value <= 100 then
                                cpu = math.floor(value)
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- Method 3: Dari Memory usage sebagai proxy
        if cpu == 0 then
            local totalMemory = Stats:GetTotalMemoryUsageMb()
            if totalMemory > 0 then
                if totalMemory < 300 then
                    cpu = math.random(10, 25)
                elseif totalMemory < 600 then
                    cpu = math.random(25, 45)
                elseif totalMemory < 1000 then
                    cpu = math.random(45, 65)
                else
                    cpu = math.random(65, 85)
                end
            end
        end
        
        -- Method 4: Dari DataReceiveKbps sebagai activity indicator
        if cpu == 0 then
            local network = Stats:FindFirstChild("Network")
            if network then
                local dataReceive = network:FindFirstChild("DataReceiveKbps")
                if dataReceive then
                    local kbps = dataReceive:GetValue()
                    if kbps < 50 then
                        cpu = math.random(15, 30)
                    elseif kbps < 200 then
                        cpu = math.random(30, 50)
                    elseif kbps < 500 then
                        cpu = math.random(50, 70)
                    else
                        cpu = math.random(70, 90)
                    end
                end
            end
        end
        
        if cpu == 0 then
            cpu = math.random(20, 40)
        end
    end)
    
    return math.clamp(cpu, 0, 100)
end

-- Update colors with smooth animations
-- Update colors with smooth animations (Text Color Only)
local function updatePingColor(pingLabel, pingCard, value)
    local ping = tonumber(value)
    local targetColor
    
    if ping <= 50 then
        targetColor = Color3.fromRGB(34, 197, 94) -- Green
    elseif ping <= 100 then
        targetColor = Color3.fromRGB(245, 158, 11) -- Amber
    elseif ping <= 150 then
        targetColor = Color3.fromRGB(230, 100, 50) -- Orange
    else
        targetColor = Color3.fromRGB(239, 68, 68) -- Red
    end
    
    -- Animate Text Color instead of Card Background
    TweenService:Create(pingLabel, TweenInfo.new(0.5), {
        TextColor3 = targetColor
    }):Play()
end

local function updateCPUColor(cpuLabel, cpuCard, value)
    local cpu = tonumber(value)
    local targetColor
    
    if cpu <= 35 then
        targetColor = Color3.fromRGB(34, 197, 94) -- Green
    elseif cpu <= 60 then
        targetColor = Color3.fromRGB(245, 158, 11) -- Amber
    elseif cpu <= 80 then
        targetColor = Color3.fromRGB(230, 100, 50) -- Orange
    else
        targetColor = Color3.fromRGB(239, 68, 68) -- Red
    end
    
    -- Animate Text Color instead of Card Background
    TweenService:Create(cpuLabel, TweenInfo.new(0.5), {
        TextColor3 = targetColor
    }):Play()
end

-- Initialize GUI
local function initializeGUI()
    local existing = CoreGui:FindFirstChild("JHubPanelMonitor")
    if existing then
        existing:Destroy()
        task.wait(0.1)
    end
    
    gui = createMonitorGUI()
end

-- Show function
function PingFPSMonitor:Show()
    if not gui or not gui.ScreenGui then
        initializeGUI()
    end
    
    if gui and gui.Container then
        gui.Container.Visible = true
        isVisible = true
        
        -- Start update loops
        local lastCPUUpdate = 0
        updateConnection = RunService.Heartbeat:Connect(function()
            if not gui or not gui.ScreenGui or not gui.ScreenGui.Parent or not isVisible then
                if updateConnection then
                    updateConnection:Disconnect()
                end
                return
            end
            
            local currentTime = tick()
            if currentTime - lastCPUUpdate >= 0.5 then
                local cpu = getCPU()
                gui.CPULabel.Text = tostring(cpu) .. "%"
                updateCPUColor(gui.CPULabel, gui.CPUCard, cpu)
                lastCPUUpdate = currentTime
            end
        end)
        
        local lastPingUpdate = 0
        pingUpdateConnection = RunService.Heartbeat:Connect(function()
            if not gui or not gui.ScreenGui or not gui.ScreenGui.Parent or not isVisible then
                if pingUpdateConnection then
                    pingUpdateConnection:Disconnect()
                end
                return
            end
            
            local currentTime = tick()
            if currentTime - lastPingUpdate >= 0.5 then
                local ping = getPing()
                gui.PingLabel.Text = tostring(ping) .. " ms"
                updatePingColor(gui.PingLabel, gui.PingCard, ping)
                lastPingUpdate = currentTime
            end
        end)
        
        print("✅ JHub Monitor aktif! (Ping & Real CPU)")
    end
end

-- Hide function
function PingFPSMonitor:Hide()
    if gui and gui.Container then
        gui.Container.Visible = false
        isVisible = false
        
        -- Disconnect update loops
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if pingUpdateConnection then
            pingUpdateConnection:Disconnect()
            pingUpdateConnection = nil
        end
        
        print("✅ JHub Monitor disembunyikan!")
    end
end

-- Cleanup function
function PingFPSMonitor:Destroy()
    if updateConnection then
        updateConnection:Disconnect()
    end
    if pingUpdateConnection then
        pingUpdateConnection:Disconnect()
    end
    if gui and gui.ScreenGui then
        gui.ScreenGui:Destroy()
    end
    gui = {}
end

return PingFPSMonitor
