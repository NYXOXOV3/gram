
-- ☠️ BLATANT V2 AUTO FISHING - INSANE MODE

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local net = RS
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Request = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Minigame = net:WaitForChild("RE/FishingMinigameChanged")

local BlatantV3beta = {}
BlatantV3.Active = false

-- 🔥 ABSURD TIMING
local CHARGE_DELAY = 0.001
local FINISH_DELAY = 0

------------------------------------------------
-- Core Brutal Loop
------------------------------------------------
local function insaneLoop()
    while BlatantV3beta.Active do
        local t = os.clock()

        task.spawn(function()
            pcall(function()
                RF_Charge:InvokeServer({[1] = t})
            end)
        end)

        task.spawn(function()
            pcall(function()
                RF_Request:InvokeServer(1, 0, os.clock())
            end)
        end)

        RunService.Heartbeat:Wait()
    end
end

------------------------------------------------
-- FORCE COMPLETE EVERYTHING
------------------------------------------------
RE_Minigame.OnClientEvent:Connect(function()
    if not BlatantV3beta.Active then return end

    task.spawn(function()
        pcall(function()
            RE_Complete:FireServer()
        end)
    end)
end)

------------------------------------------------
-- Public API
------------------------------------------------
function BlatantV3beta.Start()
    if BlatantV3beta.Active then return end
    BlatantV3beta.Active = true
    task.spawn(insaneLoop)
end

function BlatantV3beta.Stop()
    BlatantV3beta.Active = false
end

return BlatantV3beta
