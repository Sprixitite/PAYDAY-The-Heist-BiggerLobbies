local DEBUG_MODE = true

---@class Sprix_HookManager
---@field Logger Sprix_LogObj
local hookMgr = {}

if not _G.SprixLogger then
    dofile("mods/PDTHBigLobbies/lua/util/sprixlogger.lua")
end
hookMgr.Logger = hookMgr.Logger or SprixLogger.new(_G.log)

---@param class Diesel_Class
---@param fnName string
---@param hookName string
---@param clbck function
function hookMgr.PostHook(class, fnName, hookName, clbck)
    clbck = hookMgr.Logger:wrap(hookName, DEBUG_MODE, clbck)
    Hooks:PostHook(class, fnName, hookName, clbck)
end

---@param class Diesel_Class
---@param fnName string
---@param hookName string
---@param clbck function
function hookMgr.PreHook(class, fnName, hookName, clbck)
    clbck = hookMgr.Logger:wrap(hookName, DEBUG_MODE, clbck)
    Hooks:PreHook(class, fnName, hookName, clbck)
end

---@param class Diesel_Class
---@param fnName string
---@param replacement function
function hookMgr.OverrideFunction(class, fnName, replacement)
    replacement = hookMgr.Logger:wrap(fnName, DEBUG_MODE, replacement)
    Hooks:OverrideFunction(class, fnName, replacement)
end

---@param class Diesel_Class
function hookMgr.DebugClass(class)
    if not DEBUG_MODE then return end
    for fnName, v in pairs(class) do
        if type(v) == "function" then
            -- Override the function with a wrapped version of itself so we get nicer error logs
            -- Dunno wtf is up with SuperBLT/the game, but I keep getting crashlogs with nonsensical line numbers?
            -- Best guess is some combination of decomp inaccuracies & mod loader weirdness, unsure
            hookMgr.OverrideFunction(class, fnName, hookMgr.Logger:wrap(fnName, DEBUG_MODE, v))
        end
    end
end

_G.SprixHookMgr = hookMgr