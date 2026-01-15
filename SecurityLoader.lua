-- ============================================================
-- 🔒 UPDATED SECURITY LOADER v2.3.0 (FULL DEBUG VERSION)
-- ============================================================

local SecurityLoader = {}

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CONFIG = {
    VERSION = "2.3.0",
    ALLOWED_DOMAIN = "raw.githubusercontent.com",
    MAX_LOADS_PER_SESSION = 100,
    ENABLE_RATE_LIMITING = true,
    ENABLE_DOMAIN_CHECK = true,
    ENABLE_VERSION_CHECK = false,

    DEBUG = {
        ENABLED = true,      -- 🔥 MATIIN INI KALAU MAU STEALTH
        VERBOSE = true,      -- tampilkan url & detail
        PREFIX = "[SECURITY-DEBUG]"
    }
}

-- ============================================================
-- DEBUG HELPERS
-- ============================================================
local function debugLog(...)
    if CONFIG.DEBUG and CONFIG.DEBUG.ENABLED then
        print(CONFIG.DEBUG.PREFIX, ...)
    end
end

local function debugWarn(...)
    if CONFIG.DEBUG and CONFIG.DEBUG.ENABLED then
        warn(CONFIG.DEBUG.PREFIX, ...)
    end
end

-- ============================================================
-- OBFUSCATED SECRET KEY
-- ============================================================
local SECRET_KEY = "ScriptAlekkBelajarDuluGaes"

-- ============================================================
-- BASE64 TABLE
-- ============================================================
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- ============================================================
-- DECRYPT FUNCTION (DEBUGGED)
-- ============================================================
local function decrypt(enc, key)
    debugLog("Decrypt start | len:", type(enc) == "string" and #enc or "invalid")

    if type(enc) ~= "string" or enc == "" then
        debugWarn("Decrypt failed: encrypted data invalid")
        return nil
    end

    enc = enc:gsub("[^"..B64.."=]", "")

    local ok, decoded = pcall(function()
        return enc:gsub(".", function(x)
            if x == "=" then return "" end
            local f = B64:find(x) - 1
            local r = ""
            for i = 6, 1, -1 do
                r = r .. (((f >> (i - 1)) & 1) == 1 and "1" or "0")
            end
            return r
        end):gsub("%d%d%d%d%d%d%d%d", function(x)
            local c = 0
            for i = 1, 8 do
                if x:sub(i, i) == "1" then
                    c = c + 2^(8 - i)
                end
            end
            return string.char(c)
        end)
    end)

    if not ok then
        debugWarn("Decrypt base64 failed:", decoded)
        return nil
    end

    local out = {}
    for i = 1, #decoded do
        local b = decoded:byte(i)
        local k = key:byte(((i - 1) % #key) + 1)
        out[i] = string.char(bit32.bxor(b, k))
    end

    local result = table.concat(out)
    debugLog("Decrypt success | url:", CONFIG.DEBUG.VERBOSE and result or "[hidden]")
    return result
end

-- ============================================================
-- RATE LIMITING
-- ============================================================
local loadCounts = {}
local lastLoadTime = {}

local function checkRateLimit()
    if not CONFIG.ENABLE_RATE_LIMITING then
        debugLog("RateLimit disabled")
        return true
    end

    local analytics = game:GetService("RbxAnalyticsService")
    local identifier = analytics:GetClientId()
    local now = tick()

    loadCounts[identifier] = loadCounts[identifier] or 0
    lastLoadTime[identifier] = lastLoadTime[identifier] or 0

    if now - lastLoadTime[identifier] > 3600 then
        debugLog("RateLimit reset after 1 hour")
        loadCounts[identifier] = 0
    end

    if loadCounts[identifier] >= CONFIG.MAX_LOADS_PER_SESSION then
        debugWarn("RateLimit exceeded | count:", loadCounts[identifier])
        return false
    end

    loadCounts[identifier] += 1
    lastLoadTime[identifier] = now

    debugLog("RateLimit OK | count:", loadCounts[identifier])
    return true
end

-- ============================================================
-- DOMAIN VALIDATION
-- ============================================================
local function validateDomain(url)
    debugLog("ValidateDomain:", url)

    if not CONFIG.ENABLE_DOMAIN_CHECK then
        debugLog("Domain check disabled")
        return true
    end

    if not url or not url:find(CONFIG.ALLOWED_DOMAIN, 1, true) then
        debugWarn("Invalid domain detected:", url)
        return false
    end

    debugLog("Domain OK")
    return true
end

-- ============================================================
-- 🔐 ENCRYPTED MODULE URLS (TETAP PAKAI PUNYA LO)
-- ============================================================
local encryptedURLs = {
    -- ⚠️ DIPERSINGKAT DEMI PANJANG PESAN
    -- 👉 TEMPEL SEMUA encryptedURLs PUNYA LO DI SINI TANPA DIUBAH
}

-- ============================================================
-- LOAD MODULE FUNCTION (FULL TRACE)
-- ============================================================
function SecurityLoader.LoadModule(moduleName)
    debugLog("LoadModule called:", moduleName)

    if not checkRateLimit() then
        debugWarn("LoadModule aborted: rate limit")
        return nil
    end

    local encrypted = encryptedURLs[moduleName]
    if not encrypted then
        debugWarn("Module not found:", moduleName)
        return nil
    end

    local url = decrypt(encrypted, SECRET_KEY)
    if not url then
        debugWarn("Decrypt failed for module:", moduleName)
        return nil
    end

    if not validateDomain(url) then
        debugWarn("Domain validation failed")
        return nil
    end

    debugLog("HttpGet start")

    local success, result = pcall(function()
        local src = game:HttpGet(url)
        debugLog("HttpGet success | bytes:", #src)

        local fn, err = loadstring(src)
        if not fn then
            error("loadstring error: " .. tostring(err))
        end

        return fn()
    end)

    if not success then
        debugWarn("LoadModule failed:", moduleName, "|", result)
        return nil
    end

    debugLog("LoadModule success:", moduleName)
    return result
end

-- ============================================================
-- ANTI-DUMP PROTECTION (DEBUG SAFE)
-- ============================================================
function SecurityLoader.EnableAntiDump()
    debugLog("EnableAntiDump called")

    if not getrawmetatable then
        debugWarn("AntiDump unavailable: executor limitation")
        return
    end

    local mt = getrawmetatable(game)
    if not mt then
        debugWarn("Metatable not accessible")
        return
    end

    local old = mt.__namecall
    local hasNC = pcall(function() return newcclosure end) and newcclosure

    setreadonly(mt, false)

    local hook = function(self, ...)
        local method = getnamecallmethod()
        if method == "HttpGet" or method == "GetObjects" then
            debugWarn("Blocked unauthorized HttpGet")
            return ""
        end
        return old(self, ...)
    end

    mt.__namecall = hasNC and newcclosure(hook) or hook
    setreadonly(mt, true)

    debugLog("AntiDump ACTIVE")
end

-- ============================================================
-- SESSION INFO
-- ============================================================
function SecurityLoader.GetSessionInfo()
    local id = game:GetService("RbxAnalyticsService"):GetClientId()
    local info = {
        Version = CONFIG.VERSION,
        LoadCount = loadCounts[id] or 0,
        RateLimit = CONFIG.ENABLE_RATE_LIMITING,
        DomainCheck = CONFIG.ENABLE_DOMAIN_CHECK
    }

    debugLog("Session Info:", info)
    return info
end

-- ============================================================
-- INIT
-- ============================================================
print("━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 Lynx Security Loader v" .. CONFIG.VERSION)
print("🛠 Debug:", CONFIG.DEBUG.ENABLED and "ON" or "OFF")
print("━━━━━━━━━━━━━━━━━━━━━━")

return SecurityLoader
