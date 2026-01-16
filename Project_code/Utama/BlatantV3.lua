
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

local BlatantV2 = {}
BlatantV2.Active = false

-- 🔥 ABSURD TIMING
local CHARGE_DELAY = 0.001
local FINISH_DELAY = 0

------------------------------------------------
-- Core Brutal Loop
------------------------------------------------
local function insaneLoop()
    while BlatantV2.Active do
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
    if not BlatantV2.Active then return end

    task.spawn(function()
        pcall(function()
            RE_Complete:FireServer()
        end)
    end)
end)

------------------------------------------------
-- Public API
------------------------------------------------
function BlatantV2.Start()
    if BlatantV2.Active then return end
    BlatantV2.Active = true
    task.spawn(insaneLoop)
end

function BlatantV2.Stop()
    BlatantV2.Active = false
end

return BlatantV2
