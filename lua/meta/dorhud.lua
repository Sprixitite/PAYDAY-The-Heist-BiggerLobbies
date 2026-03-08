---@module "meta.diesel"

---@deprecated
---@class Dahm_ModDescription
---@field abbr string,
---@field version string,
---@field description string

---@deprecated
---@class Dahm_Mod
---@field hook_post_require fun(self: Dahm_Mod, game_file_path: string, hook_file_path: string)
---@field register_include  fun(self: Dahm_Mod, path: string)
---@field hook_class        fun(self: Dahm_Mod, name: string) : Diesel_Class

---@deprecated
---@class Dahm_DMod
---@field new fun(self: Dahm_DMod, name: string, details: Dahm_ModDescription) : Dahm_Mod
---@field module fun(self: Dahm_DMod, name: string) : Dahm_Mod
_G.D = {}

---@deprecated
---@diagnostic disable-next-line
_G.DMod = _G.D

---@deprecated
---@param ... string
_G.dorhud_log = function(...) end