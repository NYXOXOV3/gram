-- KeySystem.lua - GUI untuk verifikasi key dengan HWID lock
-- Integrasi dengan JackHub Key System API

local KeySystem = {}
KeySystem.API_URL = "https://key-system-iota-seven.vercel.app/api/verify"
KeySystem.GET_KEY_URL = "https://key-system-iota-seven.vercel.app" -- Sementara arahkan ke dashboard/home

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get HWID (using executor's method or fallback)
local function getHWID()
    local hwid = "UNKNOWN"
    pcall(function()
        if gethwid then
            hwid = gethwid()
        elseif getexecutorname then
            hwid = getexecutorname() .. "_" .. LocalPlayer.UserId
        else
            hwid = tostring(LocalPlayer.UserId) .. "_" .. tostring(game.PlaceId)
        end
    end)
    return hwid
end

-- Create the Key System GUI
function KeySystem.CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "JackHubKeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Background blur
    local blur = Instance.new("Frame")
    blur.Name = "Blur"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blur.BackgroundTransparency = 0.3
    blur.BorderSizePixel = 0
    blur.Parent = gui

    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 280)
    container.Position = UDim2.new(0.5, -200, 0.5, -140)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = gui
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = container

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔐 JackHub Key System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = container

    -- Key input box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "KeyInput"
    inputBox.Size = UDim2.new(0, 340, 0, 45)
    inputBox.Position = UDim2.new(0.5, -170, 0, 70)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = "Enter your key here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 10)

    -- Status label
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 30)
    status.Position = UDim2.new(0, 20, 0, 125)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = container

    -- Verify button
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Name = "VerifyButton"
    verifyBtn.Size = UDim2.new(0, 340, 0, 45)
    verifyBtn.Position = UDim2.new(0.5, -170, 0, 160)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Text = "✓ Verify Key"
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.TextSize = 16
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = container
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 10)

    -- Get Key button
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Name = "GetKeyButton"
    getKeyBtn.Size = UDim2.new(0, 165, 0, 40)
    getKeyBtn.Position = UDim2.new(0.5, -170, 0, 215)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "🔑 Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    getKeyBtn.TextSize = 14
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.AutoButtonColor = false
    getKeyBtn.Parent = container
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

    -- Discord button
    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordButton"
    discordBtn.Size = UDim2.new(0, 165, 0, 40)
    discordBtn.Position = UDim2.new(0.5, 5, 0, 215)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.BackgroundTransparency = 0.5
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "💬 Discord"
    discordBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    discordBtn.TextSize = 14
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = container
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)

    return gui, inputBox, status, verifyBtn, getKeyBtn, discordBtn
end

-- Verify key with API
function KeySystem.VerifyKey(key)
    local hwid = getHWID()
    
    local success, response = pcall(function()
        return request({
            Url = KeySystem.API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = hwid })
        })
    end)
    
    if not success then
        return false, "Request failed. Check your executor."
    end
    
    local ok, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)
    
    if not ok then
        return false, "Invalid server response"
    end
    
    return data.valid == true, data.message or "Unknown error"
end

-- Main function - shows GUI and returns true if verified
function KeySystem.Show()
    local verified = false
    local gui, inputBox, status, verifyBtn, getKeyBtn, discordBtn = KeySystem.CreateGUI()
    
    -- Hover effects
    verifyBtn.MouseEnter:Connect(function()
        TweenService:Create(verifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 115, 255)}):Play()
    end)
    verifyBtn.MouseLeave:Connect(function()
        TweenService:Create(verifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    
    -- Get Key button
    getKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(KeySystem.GET_KEY_URL)
            status.Text = "Link copied to clipboard!"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            status.Text = "Open: " .. KeySystem.GET_KEY_URL
            status.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)
    
    -- Verify button
    verifyBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text
        if key == "" then
            status.Text = "Please enter a key!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        verifyBtn.Text = "Verifying..."
        status.Text = ""
        
        local valid, message = KeySystem.VerifyKey(key)
        
        if valid then
            status.Text = "✓ " .. message
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            verifyBtn.Text = "✓ Verified!"
            verifyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            
            -- Fade out and destroy
            task.wait(1)
            TweenService:Create(gui:FindFirstChild("Blur"), TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            TweenService:Create(gui:FindFirstChild("Container"), TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.wait(0.5)
            gui:Destroy()
            verified = true
        else
            status.Text = "✗ " .. message
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            verifyBtn.Text = "✓ Verify Key"
        end
    end)
    
    -- Wait for verification
    repeat task.wait(0.1) until verified or not gui.Parent
    
    return verified
end

return KeySystem
