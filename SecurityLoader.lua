--=====================================================
-- JackHub Security Loader (CLEAN & MAINTAINABLE)
-- Version : 2.3.0
--=====================================================

local SecurityLoader = {}

--=====================================================
-- CONFIG
--=====================================================
local CONFIG = {
    VERSION = "2.3.0",
    ALLOWED_DOMAIN = "raw.githubusercontent.com",
    MAX_LOADS_PER_SESSION = 100,

    ENABLE_RATE_LIMITING = true,
    ENABLE_DOMAIN_CHECK = true,
    ENABLE_VERSION_CHECK = false,
}

--=====================================================
-- SECRET KEY (OBFUSCATED)
--=====================================================
local SECRET_KEY = table.concat({
    string.char(76,121,110,120),   -- Lynx
    string.char(71,85,73,95),      -- GUI_
    "SuperSecret_",
    "2024",
    string.char(33,64,35,36,37,94)
})

--=====================================================
-- INTERNAL STATE
--=====================================================
local loadCounts = {}
local lastLoadTime = {}

local Analytics = game:GetService("RbxAnalyticsService")

--=====================================================
-- UTILS
--=====================================================
local function _getClientId()
    return Analytics:GetClientId()
end

--=====================================================
-- DECRYPTION
--=====================================================
local function _decryptBase64XOR(encrypted, key)
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    encrypted = encrypted:gsub("[^"..b64.."=]", "")

    local decoded = encrypted:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (b64:find(x) - 1)
        for i = 6, 1, -1 do
            r ..= (f % 2^i - f % 2^(i - 1) > 0) and "1" or "0"
        end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do
            if x:sub(i, i) == "1" then
                c += 2^(8 - i)
            end
        end
        return string.char(c)
    end)

    local out = table.create(#decoded)
    for i = 1, #decoded do
        out[i] = string.char(
            bit32.bxor(
                string.byte(decoded, i),
                string.byte(key, ((i - 1) % #key) + 1)
            )
        )
    end

    return table.concat(out)
end

--=====================================================
-- RATE LIMIT
--=====================================================
local function _checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        return true
    end

    local id = _getClientId()
    local now = tick()

    loadCounts[id] = loadCounts[id] or 0
    lastLoadTime[id] = lastLoadTime[id] or 0

    if now - lastLoadTime[id] > 3600 then
        loadCounts[id] = 0
    end

    if loadCounts[id] >= CONFIG.MAX_LOADS_PER_SESSION then
        warn("⚠️ Rate limit exceeded")
        return false
    end

    loadCounts[id] += 1
    lastLoadTime[id] = now
    return true
end

--=====================================================
-- DOMAIN CHECK
--=====================================================
local function _validateDomain(url)
    if not CONFIG.ENABLE_DOMAIN_CHECK then
        return true
    end
    if not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        warn("🚫 Blocked domain:", url)
        return false
    end
    return true
end

--=====================================================
-- ENCRYPTED URL MAP
--=====================================================
local encryptedURLs = {
    instant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6ADEgARELBn0JFhM=",
    instant2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6ADEgARELBmFLDwcE",
    blatantv1 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKMD8EFxMLAAkDHl5BQA==",
    UltraBlatant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKMD8EFxMLAAkAHl5BQA==",
    blatantv2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6CzMyARELBgVXTR4QFQ==",
    blatantv2fix = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKMD8EFxMLABlbSFdQd3ENSFA/",
    NoFishingAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKPDwjCgENHTFVcVxdTCFXTUowYhUbGQ==",
    LockPosition = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKPjwGCCIKBzZGWV1aDyxWRQ==",
    AutoEquipRod = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKMyYRDDcUATZCYl1QDyxWRQ==",
    DisableCutscenes = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKNjoWAhAJERxHREFXRC5GVwsyORg=",
    DisableExtras = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKNjoWAhAJERpKREBVUm5PUUQ=",
    AutoTotem3X = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKMyYRDCYKADpfA0oaTTVC",
    SkinAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKITgMDSESFS9zXltZQDRKS0twIAwP",
    WalkOnWater = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKJTIJCD0LIz5GVUAaTTVC",
    TeleportModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HTo/EAAKACcoDBYQGDocXEdV",
    TeleportToPlayer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HTo/EAAKACc2GgERETIdZFdYRDBMVlEKIykCGT4wO3E/ABE=",
    SavedLocation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HTo/EAAKACc2GgERETIdY1NCRCRvS0Y/OBABFmk5PD4=",
    AutoQuestModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6GCo2BgRKMyYRDCMQESxGfV1QVCxGCkkrLQ==",
    AutoTemple = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6GCo2BgRKPjYTBgA0ATpBRBxYVCE=",
    TempleDataReader = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6GCo2BgRKJjYIEx4AMD5GUWBRQCRGVgsyORg=",
    AutoSell = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWx5HRF1nRCxPCkkrLQ==",
    AutoSellTimer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWx5HRF1nRCxPcEwzKQtAFDI0",
    MerchantSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWxBCVVxnSS9TCkkrLQ==",
    RemoteBuyer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWw1XXV1ARAJWXUAsYhUbGQ==",
    FreecamModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Cj4+EAIEV2FVNRsAA3B0QldRQiFOaUo6ORULVisgKA==",
    UnlimitedZoomModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Cj4+EAIEV2FVNRsAA3BnXl5dTClXQUEEIxYDVisgKA==",
    AntiAFK = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8kHCcMIjQuWjNHUQ==",
    UnlockFPS = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8wHD8KABkjJAwcXEdV",
    FPSBooster = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8jAiAnDB0WADpAHl5BQA==",
    AutoBuyWeather = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWx5HRF12VDl0QUQqJBwcVisgKA==",
    Notify = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HTo/EAAKACc2GgERETIdfl1ASCZKR0QqJRYANSgxPDM2WxwQEw==",
    
    -- ✅ NEW: EventTeleportDynamic (ADDED)
    EventTeleportDynamic = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HTo/EAAKACc2GgERETIddURRTzR3QUk7PBYcDAMsJz4+HBNLHiYE",
    
    -- ✅ EXISTING: HideStats & Webhook (already encrypted)
    HideStats = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8tGzcAMAYEACwcXEdV",
    Webhook = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8yFzENDB0OWjNHUQ==",
    GoodPerfectionStable = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6HCsyGBFKIjYXBRcGADZdXnVbTiQNSFA/",
    DisableRendering = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8hGyAEAR4AJjpcVFdGSC5ECkkrLQ==",
    AutoFavorite = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6CConGjYEBDwXCgYAWjNHUQ==",
    PingFPSMonitor = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl81Gz0CMxMLETMcXEdV",
    MovementModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8oHSUADhcLABJdVEdYRG5PUUQ=",
    AutoSellSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6Gjc8BTYAEycQERcWWx5HRF1nRCxPd1wtOBwDVisgKA==",
    ManualSave = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KGT5bXh1kUy9JQUYqExoBHCJ6BDYgFl8oEz0QAh42FSlXHl5BQA==",
    EventTeleportDynamic = "...",
}

--=====================================================
-- PUBLIC API : LOAD MODULE
--=====================================================
function SecurityLoader.LoadModule(name)
    if not _checkRateLimit() then return nil end

    local encrypted = encryptedURLs[name]
    if not encrypted then
        warn("❌ Module not found:", name)
        return nil
    end

    local url = _decryptBase64XOR(encrypted, SECRET_KEY)
    if not _validateDomain(url) then return nil end

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn("❌ Load failed:", name, result)
        return nil
    end

    return result
end

--=====================================================
-- ANTI-DUMP (SAFE MODE)
--=====================================================
function SecurityLoader.EnableAntiDump()
    local mt = getrawmetatable(game)
    if not mt then
        warn("⚠️ AntiDump: no metatable")
        return
    end

    local old = mt.__namecall
    local wrap = function(self, ...)
        local method = getnamecallmethod()
        if method == "HttpGet" and getcallingscript() ~= script then
            warn("🚫 Unauthorized HttpGet blocked")
            return ""
        end
        return old(self, ...)
    end

    setreadonly(mt, false)
    mt.__namecall = newcclosure and newcclosure(wrap) or wrap
    setreadonly(mt, true)

    print("🛡️ AntiDump ACTIVE")
end

--=====================================================
-- INFO
--=====================================================
function SecurityLoader.GetSessionInfo()
    local total = 0
    for _ in pairs(encryptedURLs) do total += 1 end

    return {
        Version = CONFIG.VERSION,
        ClientLoads = loadCounts[_getClientId()] or 0,
        TotalModules = total,
        RateLimit = CONFIG.ENABLE_RATE_LIMITING,
        DomainCheck = CONFIG.ENABLE_DOMAIN_CHECK
    }
end

function SecurityLoader.ResetRateLimit()
    local id = _getClientId()
    loadCounts[id] = 0
    lastLoadTime[id] = 0
end

print("🔒 JackHub Security Loader v"..CONFIG.VERSION.." loaded")

return SecurityLoader
