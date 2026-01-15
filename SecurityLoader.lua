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
    instant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAaGwMREz0RTR4QFQ==",
    instant2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAaGwMREz0RUVwJAT4=",
    blatantv1 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wnDxMRFTFGZgMaTTVC",
    UltraBlatant = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wnDxMRFTFGZgAaTTVC",
    blatantv2 = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHARGREREz0RNUBLGCpT",
    blatantv2fix = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wnDxMRFTFGdltMRCR1FQsyORg=",
    NoFishingAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wrDDQMBzdbXlV1TylORVE3IxdAFDI0",
    LockPosition = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wpDBEOJDBBWUZdTi4NSFA/",
    AutoEquipRod = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wkFgYKMS5HWUJmTiQNSFA/",
    DisableCutscenes = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3whCgEEFjNXc0dAUiNGSkAtYhUbGQ==",
    DisableExtras = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3whCgEEFjNXdUpAUyFQCkkrLQ==",
    AutoTotem3X = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wkFgYKIDBGVV8HWW5PUUQ=",
    SkinAnimation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3w2CBsLJyhTQHNaSC1CUEwxIlcCDSY=",
    WalkOnWater = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3wyAh4OOzFlUUZRU25PUUQ=",
    TeleportModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAHEBwAAjwXFz8KECpeVRxYVCE=",
    TeleportToPlayer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAHEBwAAjwXFyEcBytXXR1gRCxGVEosOC0BKCs0MDohWxwQEw==",
    SavedLocation = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAHEBwAAjwXFyEcBytXXR1nQDZGQGkxLxgaESg7ZzMmFA==",
    AutoQuestModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHACABUWBnwkFgYKJSpXQ0Z5TiRWSEBwIAwP",
    AutoTemple = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHACABUWBnwpBgQABg5HVUFADyxWRQ==",
    TempleDataReader = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHACABUWBnwxBh8VGDp2UUZVcyVCQEAsYhUbGQ==",
    AutoSell = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdcUdAThNGSElwIAwP",
    AutoSellTimer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdcUdAThNGSEkKJRQLCmk5PD4=",
    MerchantSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdf0JRTxNLS1VwIAwP",
    RemoteBuyer = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdYldZTjRGZlAnKQtAFDI0",
    FreecamModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAQFB0AADJAUUIzHTpFH3RGRCVARUgTIx0bFCJ7JSoy",
    UnlimitedZoomModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAQFB0AADJAUUIzHTpFH2daTSlOTVE7KCMBFyp7JSoy",
    AntiAFK = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXRILFxskMhQcXEdV",
    UnlockFPS = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXQYLDx0GHxliYxxYVCE=",
    FPSBooster = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXRUVEDAKGyxGVUAaTTVC",
    AutoBuyWeather = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdcUdATgJWXXI7LQ0GHTV7JSoy",
    Notify = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAHEBwAAjwXFyEcBytXXR16TjRKQkw9LQ0HFykYJjsmGRVLHiYE",
    
    -- ✅ NEW: EventTeleportDynamic (ADDED)
    EventTeleportDynamic = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAHEBwAAjwXFyEcBytXXR1xVyVNUHE7IBweFzUhDSY9FB0MEX0JFhM=",
    
    -- ✅ EXISTING: HideStats & Webhook (already encrypted)
    HideStats = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXRsMBxc2AD5GQxxYVCE=",
    Webhook = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXQQAARoKGzQcXEdV",
    GoodPerfectionStable = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAGAREIE3w1BgADETxGWV1aZi9MQAsyORg=",
    DisableRendering = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXRcMEBMHGDpgVVxQRDJKSkJwIAwP",
    AutoFavorite = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHASAAQKNDITDAAMADocXEdV",
    PingFPSMonitor = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXQMMDRU1FTFXXBxYVCE=",
    MovementModule = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXR4KFRcIETFGfV1QVCxGCkkrLQ==",
    AutoSellSystem = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAAHR8VNDYEFwcXESwdcUdAThNGSEkNNQoaHSp7JSoy",
    ManualSave = "JA0aCDRvZnAhFAdLFToRCwcHASxXQlFbTzRGSlFwLxYDVyonICYyR0NKNDoWC18sAHBfUVtaDhBRS087Lw0xGygxLHAeHAMGXR4EDQcEGAxTRlcaTTVC",
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
