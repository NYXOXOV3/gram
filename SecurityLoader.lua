-- UPDATED SECURITY LOADER - Includes EventTeleportDynamiefws
-- Replace your SecurityLoader.lua with this

local SecurityLoader = {}

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
    VERSION = "2.3.0",
    ALLOWED_DOMAIN = "raw.githubusercontent.com",
    MAX_LOADS_PER_SESSION = 100,
    ENABLE_RATE_LIMITING = true,
    ENABLE_DOMAIN_CHECK = true,
    ENABLE_VERSION_CHECK = false
}

-- ============================================
-- OBFUSCATED SECRET KEY
-- ============================================
local SECRET_KEY = (function()
    local parts = {
        string.char(76, 121, 110, 120),
        string.char(71, 85, 73, 95),
        "SuperSecret_",
        tostring(2024),
        string.char(33, 64, 35, 36, 37, 94)
    }
    return table.concat(parts)
end)()

-- ============================================
-- DECRYPTION FUNCTION
-- ============================================
local function decrypt(encrypted, key)
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    encrypted = encrypted:gsub('[^'..b64..'=]', '')
    
    local decoded = (encrypted:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64:find(x)-1)
        for i=6,1,-1 do 
            r = r .. (f%2^i-f%2^(i-1)>0 and '1' or '0') 
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i=1,8 do 
            c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) 
        end
        return string.char(c)
    end))
    
    local result = {}
    for i = 1, #decoded do
        local byte = string.byte(decoded, i)
        local keyByte = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    
    return table.concat(result)
end

-- ============================================
-- RATE LIMITING
-- ============================================
local loadCounts = {}
local lastLoadTime = {}

local function checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        return true
    end
    
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    local currentTime = tick()
    
    loadCounts[identifier] = loadCounts[identifier] or 0
    lastLoadTime[identifier] = lastLoadTime[identifier] or 0
    
    if currentTime - lastLoadTime[identifier] > 3600 then
        loadCounts[identifier] = 0
    end
    
    if loadCounts[identifier] >= CONFIG.MAX_LOADS_PER_SESSION then
        warn("⚠️ Rate limit exceeded. Please wait before reloading.")
        return false
    end
    
    loadCounts[identifier] = loadCounts[identifier] + 1
    lastLoadTime[identifier] = currentTime
    
    return true
end

-- ============================================
-- DOMAIN VALIDATION
-- ============================================
local function validateDomain(url)
    if not CONFIG.ENABLE_DOMAIN_CHECK then
        return true
    end
    
    if not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        warn("🚫 Security: Invalid domain detected")
        return false
    end
    
    return true
end

-- ============================================
-- ENCRYPTED MODULE URLS (ALL 28 MODULES)
-- ============================================
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
}

-- ============================================
-- LOAD MODULE FUNCTION
-- ============================================
function SecurityLoader.LoadModule(moduleName)
    if not checkRateLimit() then
        return nil
    end
    
    local encrypted = encryptedURLs[moduleName]
    if not encrypted then
        warn("❌ Module not found:", moduleName)
        return nil
    end
    
    local url = decrypt(encrypted, SECRET_KEY)
    
    if not validateDomain(url) then
        return nil
    end
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("❌ Failed to load", moduleName, ":", result)
        return nil
    end
    
    return result
end

-- ============================================
-- ANTI-DUMP PROTECTION (COMPATIBLE VERSION)
-- ============================================
function SecurityLoader.EnableAntiDump()
    local mt = getrawmetatable(game)
    if not mt then 
        warn("⚠️ Anti-Dump: Metatable not accessible")
        return 
    end
    
    local oldNamecall = mt.__namecall
    
    -- Check if newcclosure is available
    local hasNewcclosure = pcall(function() return newcclosure end) and newcclosure
    
    local success = pcall(function()
        setreadonly(mt, false)
        
        local protectedCall = function(self, ...)
            local method = getnamecallmethod()
            
            if method == "HttpGet" or method == "GetObjects" then
                local caller = getcallingscript and getcallingscript()
                if caller and caller ~= script then
                    warn("🚫 Blocked unauthorized HTTP request")
                    return ""
                end
            end
            
            return oldNamecall(self, ...)
        end
        
        -- Use newcclosure if available, otherwise use regular function
        mt.__namecall = hasNewcclosure and newcclosure(protectedCall) or protectedCall
        
        setreadonly(mt, true)
    end)
    
    if success then
        print("🛡️ Anti-Dump Protection: ACTIVE")
    else
        warn("⚠️ Anti-Dump: Failed to apply (executor limitation)")
    end
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function SecurityLoader.GetSessionInfo()
    local info = {
        Version = CONFIG.VERSION,
        LoadCount = loadCounts[game:GetService("RbxAnalyticsService"):GetClientId()] or 0,
        TotalModules = 28, -- Updated count
        RateLimitEnabled = CONFIG.ENABLE_RATE_LIMITING,
        DomainCheckEnabled = CONFIG.ENABLE_DOMAIN_CHECK
    }
    
    print("━━━━━━━━━━━━━━━━━━━━━━")
    print("📊 Session Info:")
    for k, v in pairs(info) do
        print(k .. ":", v)
    end
    print("━━━━━━━━━━━━━━━━━━━━━━")
    
    return info
end

function SecurityLoader.ResetRateLimit()
    local identifier = game:GetService("RbxAnalyticsService"):GetClientId()
    loadCounts[identifier] = 0
    lastLoadTime[identifier] = 0
    print("✅ Rate limit reset")
end

print("━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 NyxHub Security Loader v" .. CONFIG.VERSION)
print("✅ Total Modules: 28 (EventTeleport added!)")
print("✅ Rate Limiting:", CONFIG.ENABLE_RATE_LIMITING and "ENABLED" or "DISABLED")
print("✅ Domain Check:", CONFIG.ENABLE_DOMAIN_CHECK and "ENABLED" or "DISABLED")
print("━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader
