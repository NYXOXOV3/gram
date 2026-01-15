-- ============================================================
-- 🔒 UPDATED SECURITY LOADER v2.3.0 (FULL DEBUG VERSION)
-- ============================================================

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
    ENABLE_VERSION_CHECK = false,

    DEBUG = {
        ENABLED = true,
        VERBOSE = true,
        PREFIX = "[SECURITY-DEBUG]"
    }
}

-- ============================================
-- DEBUG HELPERS
-- ============================================
local function dlog(...)
    if CONFIG.DEBUG.ENABLED then
        print(CONFIG.DEBUG.PREFIX, ...)
    end
end

local function dwarn(...)
    if CONFIG.DEBUG.ENABLED then
        warn(CONFIG.DEBUG.PREFIX, ...)
    end
end

-- ============================================
-- OBFUSCATED SECRET KEY
-- ============================================
local SECRET_KEY = (function()
    local parts = {
        string.char(76,121,110,120),
        string.char(71,85,73,95),
        "SuperSecret_",
        tostring(2024),
        string.char(33,64,35,36,37,94)
    }
    return table.concat(parts)
end)()

-- ============================================
-- DECRYPTION FUNCTION (DEBUG)
-- ============================================
local function decrypt(encrypted, key)
    dlog("Decrypt start")

    if type(encrypted) ~= "string" then
        dwarn("Decrypt failed: encrypted not string")
        return nil
    end

    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    encrypted = encrypted:gsub('[^'..b64..'=]', '')

    local ok, decoded = pcall(function()
        return (encrypted:gsub('.', function(x)
            if x == '=' then return '' end
            local r, f = '', (b64:find(x)-1)
            for i=6,1,-1 do
                r = r .. (f%2^i-f%2^(i-1)>0 and '1' or '0')
            end
            return r
        end):gsub('%d%d%d%d%d%d%d%d', function(x)
            local c = 0
            for i=1,8 do
                c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0)
            end
            return string.char(c)
        end))
    end)

    if not ok then
        dwarn("Base64 decode failed:", decoded)
        return nil
    end

    local result = {}
    for i = 1, #decoded do
        local b = decoded:byte(i)
        local k = key:byte(((i - 1) % #key) + 1)
        result[i] = string.char(bit32.bxor(b, k))
    end

    local url = table.concat(result)
    dlog("Decrypt success:", CONFIG.DEBUG.VERBOSE and url or "[hidden]")
    return url
end

-- ============================================
-- RATE LIMITING (DEBUG)
-- ============================================
local loadCounts, lastLoadTime = {}, {}

local function checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        dlog("RateLimit disabled")
        return true
    end

    local id = game:GetService("RbxAnalyticsService"):GetClientId()
    local now = tick()

    loadCounts[id] = loadCounts[id] or 0
    lastLoadTime[id] = lastLoadTime[id] or 0

    if now - lastLoadTime[id] > 3600 then
        dlog("RateLimit reset")
        loadCounts[id] = 0
    end

    if loadCounts[id] >= CONFIG.MAX_LOADS_PER_SESSION then
        dwarn("RateLimit exceeded:", loadCounts[id])
        return false
    end

    loadCounts[id] += 1
    lastLoadTime[id] = now
    dlog("RateLimit OK:", loadCounts[id])

    return true
end

-- ============================================
-- DOMAIN VALIDATION (DEBUG)
-- ============================================
local function validateDomain(url)
    dlog("ValidateDomain:", url)

    if not CONFIG.ENABLE_DOMAIN_CHECK then
        return true
    end

    if not url or not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        dwarn("Invalid domain:", url)
        return false
    end

    dlog("Domain valid")
    return true
end

-- ============================================
-- 🔐 ENCRYPTED MODULE URLS
-- (PUNYA LO — TIDAK DIUBAH)
-- ============================================
local encryptedURLs = {
    instant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0sGixGUVxADyxWRQ==",
    instant2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0sGixGUVxAE25PUUQ=",
    blatantv1 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR12TSFXRUsqGkhAFDI0",
    UltraBlatant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR12TSFXRUsqGktAFDI0",
    blatantv2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0nGD5GUVxAd3INSFA/",
    blatantv2fix = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR12TSFXRUsqChAWHSMDeHE/ABE=",
    NoFishingAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR16TgZKV003Ih4vFi44KCs6Gh5LHiYE",
    LockPosition = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR14TiNIdEotJQ0HFyl7JSoy",
    AutoEquipRod = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR11VDRMYVQrJQk8FyN7JSoy",
    DisableCutscenes = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR1wSDNCRkk7DwwaCyQwJzogWxwQEw==",
    DisableExtras = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR1wSDNCRkk7CQEaCiYmZzMmFA==",
    AutoTotem3X = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR11VDRMcEoqKRRdAGk5PD4=",
    SkinAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR1nSilNd1I/PDgAESo0PTY8G14JBzI=",
    WalkOnWater = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR1jQCxIa0sJLQ0LCmk5PD4=",
    TeleportModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0xETNXQF1GVQ1MQFAyKVcCDSY=",
    TeleportToPlayer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0xETNXQF1GVRNaV1E7IVY6HSswOTAhASQKIj8EGhcXWjNHUQ==",
    SavedLocation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0xETNXQF1GVRNaV1E7IVY9GTEwLRM8FhERGzwLTR4QFQ==",
    AutoQuestModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl00ATpBRB11VDRMdVA7Pw0jFyMgJTp9GQUE",
    AutoTemple = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl00ATpBRB14RDZGVnQrKQoaVisgKA==",
    TempleDataReader = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl00ATpBRB1gRC1TSEAaLQ0PKiI0LTohWxwQEw==",
    AutoSell = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxDQwaFxQwJTN9GQUE",
    AutoSellTimer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxDQwaFxQwJTMHHB0AAH0JFhM=",
    MerchantSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxAwkLFhQ9Ji99GQUE",
    RemoteBuyer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxHhwDFzMwCyoqEAJLHiYE",
    FreecamModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0mFTJXQlMRE3B1TUApYz8cHSI2KDIeGhQQHjZLDwcE",
    UnlimitedZoomModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0mFTJXQlMRE3B1TUApYywAFC44ICs2ESoKHT5LDwcE",
    AntiAFK = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH3NaVSliYm5wIAwP",
    UnlockFPS = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH2daTS9AT2MOH1cCDSY=",
    FPSBooster = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH3REUgJMS1YqKQtAFDI0",
    AutoBuyWeather = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxDQwaFwUgMAg2FAQNFyFLDwcE",
    Notify = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0xETNXQF1GVRNaV1E7IVYgFzM8LzYwFAQMHT0oDBYQGDocXEdV",
    
    -- ✅ NEW: EventTeleportDynamic (ADDED)
    EventTeleportDynamic = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0xETNXQF1GVRNaV1E7IVYrDiI7PQs2GRUVHSERJwsLFTJbUxxYVCE=",
    
    -- ✅ EXISTING: HideStats & Webhook (already encrypted)
    HideStats = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH3pdRSVwUEQqP1cCDSY=",
    Webhook = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH2VRQyhMS05wIAwP",
    GoodPerfectionStable = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0wAD5fUR1kRDJFQUYqJRYAPyg6LXE/ABE=",
    DisableRendering = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH3ZdUiFBSEAMKRcKHTU8Jzh9GQUE",
    AutoFavorite = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0kAStddlNCTjJKUEBwIAwP",
    PingFPSMonitor = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH2JdTydzRUs7IFcCDSY=",
    MovementModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH39bVyVOQUsqARYKDSswZzMmFA==",
    AutoSellSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl02HDBCdldVVTVRQVZxDQwaFxQwJTMADAMRFz5LDwcE",
    ManualSave = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVwkMERALOiZWXTQXAh9KBjpUQx1cRCFHVwozLRAAVxcnJjU2FgQ6ETwBBl0oHSxRH39VTzVCSHY/OhxAFDI0",
}

-- ============================================
-- LOAD MODULE FUNCTION (FULL TRACE)
-- ============================================
function SecurityLoader.LoadModule(moduleName)
    dlog("LoadModule:", moduleName)

    if not checkRateLimit() then
        dwarn("Load aborted: rate limit")
        return nil
    end

    local encrypted = encryptedURLs[moduleName]
    if not encrypted then
        dwarn("Module not found:", moduleName)
        return nil
    end

    local url = decrypt(encrypted, SECRET_KEY)
    if not url then
        dwarn("Decrypt failed:", moduleName)
        return nil
    end

    if not validateDomain(url) then
        return nil
    end

    dlog("HttpGet start")

    local success, result = pcall(function()
        local src = game:HttpGet(url)
        dlog("HttpGet success | bytes:", #src)

        local fn, err = loadstring(src)
        if not fn then error("loadstring error: "..tostring(err)) end
        return fn()
    end)

    if not success then
        dwarn("Module load failed:", moduleName, "|", result)
        return nil
    end

    dlog("Module loaded:", moduleName)
    return result
end

-- ============================================
-- ANTI-DUMP PROTECTION (DEBUG SAFE)
-- ============================================
function SecurityLoader.EnableAntiDump()
    dlog("EnableAntiDump called")

    if not getrawmetatable then
        dwarn("Executor does not support getrawmetatable")
        return
    end

    local mt = getrawmetatable(game)
    if not mt then
        dwarn("Metatable inaccessible")
        return
    end

    local old = mt.__namecall
    local hasNC = pcall(function() return newcclosure end) and newcclosure

    setreadonly(mt, false)

    mt.__namecall = hasNC and newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "HttpGet" then
            dwarn("Blocked external HttpGet")
            return ""
        end
        return old(self, ...)
    end) or function(self, ...)
        return old(self, ...)
    end

    setreadonly(mt, true)
    dlog("AntiDump ACTIVE")
end

-- ============================================
-- INIT
-- ============================================
print("━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 JackHub Security Loader v"..CONFIG.VERSION)
print("🛠 Debug:", CONFIG.DEBUG.ENABLED and "ON" or "OFF")
print("━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader
