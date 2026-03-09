local DEBUG_MODE = true

---@class Sprix_HookManager
---@field Logger Sprix_LogObj
local hookMgr = _G.SprixHookMgr or {}

if not _G.SprixLogger then
    dofile("mods/PDTHBigLobbies/lua/util/sprixlogger.lua")
end
hookMgr.Logger = hookMgr.Logger or SprixLogger.new(_G.log)

function hookMgr.PostHook(class, fnName, hookName, clbck)
    clbck = hookMgr.Logger:wrap(hookName, DEBUG_MODE, clbck)
    Hooks:PostHook(class, fnName, hookName, clbck)
end

function hookMgr.PreHook(class, fnName, hookName, clbck)
    clbck = hookMgr.Logger:wrap(hookName, DEBUG_MODE, clbck)
    Hooks:PreHook(class, fnName, hookName, clbck)
end

function hookMgr.OverrideHook(class, fnName, replacement)
    replacement = hookMgr.Logger:wrap(fnName, DEBUG_MODE, replacement)
    Hooks:OverrideFunction(class, fnName, replacement)
end

_G.SprixHookMgr = hookMgr