---@meta

---@class Hooks
---@field OverrideFunction fun(self: Hooks, class: table, fnName: string, replacement: function)
---@field PostHook fun(self: Hooks, class: table, fnName: string, hookName: string, clbck: function)
---@field PreHook  fun(self: Hooks, class: table, fnName: string, hookName: string, clbck: function)
_G.Hooks = {}

---@param ... any
_G.log = function(...) end

_G.pcall = nil

---@class BLT_Global
---@field pcall fun(fn: function, ...: any) : boolean, ...
_G.blt = {}