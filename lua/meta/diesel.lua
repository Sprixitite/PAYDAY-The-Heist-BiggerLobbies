---@meta

---@class Diesel_Idstring
---@field key fun(self: Diesel_Idstring) : string

--- Diesel's core Color class, all values are in the range 0-1
---@class Diesel_Color
---@field a number
---@field r number
---@field g number
---@field b number
---@field x number
---@field y number
---@field z number
---@field alpha number
---@field red   number
---@field green number
---@field blue  number
---@field with_alpha fun(self: Diesel_Color, a: number) : Diesel_Color

---@class Diesel_Vec3
---@field x number
---@field y number
---@field z number

---@class Diesel_Rotation
---@field yaw   fun(self: Diesel_Rotation) : number
---@field pitch fun(self: Diesel_Rotation) : number
---@field roll  fun(self: Diesel_Rotation) : number

---@class Diesel_Video

---@class Diesel_Rect
---@field x number
---@field y number
---@field width number
---@field height number

---@class Diesel_MVec3
---@field normalize fun(vec: Diesel_Vec3) : Diesel_Vec3
---@field set_z fun(vec: Diesel_Vec3, to: number) : Diesel_Vec3
_G.mvector3 = {}

---@class Diesel_Class<SuperT>
---@field super SuperT

---@class Diesel_Application
---@field editor fun(self: Diesel_Application) : boolean
_G.Application = {}

---@class Diesel_Unit
---@field key fun(self: Diesel_Unit) : string
---@field movement function
---@field brain function

---@param obj any
---@return string
_G.type_name = function(obj) end

---@param unit Diesel_Unit
---@return boolean
_G.alive = function(unit) end

---@class Diesel_GameStateMachine
---@field change_state_by_name function
---@field last_queued_state_name fun(self: Diesel_GameStateMachine) : string
_G.game_state_machine = {}

---@class Diesel_World
---@field spawn_unit fun(self: Diesel_World, unit_name: Diesel_Idstring, spawn_pos: Diesel_Vec3, spawn_rot: Diesel_Rotation) : Diesel_Unit
_G.World = {}

---@class Diesel_ViewportManager
---@field get_safe_rect_pixels fun(self: Diesel_ViewportManager) : Diesel_Rect
_G.ViewportManager = {}

---@class Diesel_RenderSettings
---@field resolution Diesel_Vec3
_G.RenderSettings = {}

---@class Diesel_Managers
---@field viewport Diesel_ViewportManager
_G.managers = {}

---@type table
_G.Global = {}

---@type Diesel_Vec3
math.UP = nil

---@param value number
---@param lower number
---@param upper number
---@return number
math.clamp = function(value, lower, upper) end

---@param tbl table
---@return number
table.size = function(tbl) end

---@param to_idstring any
---@return Diesel_Idstring
_G.Idstring = function(to_idstring) end

--- Generate a rotation from a `yaw`, `pitch`, and `roll`
---@param yaw number
---@param pitch number
---@param roll number
---@return Diesel_Rotation
_G.rotation = function(yaw, pitch, roll) end

--- Generate a rotation by `amt` around the axis `about`
---@param amt number
---@param about Diesel_Vec3
---@return Diesel_Rotation
_G.Rotation = function(amt, about) end

---@overload fun() : Diesel_Vec3
---@overload fun(x: number, y: number) : Diesel_Vec3
---@param x number
---@param y number
---@param z number
---@return Diesel_Vec3
_G.Vector3 = function(x, y, z) end

---@overload fun() : Diesel_Color
---@overload fun(hex: string) : Diesel_Color
---@overload fun(r: number, g: number, b: number) : Diesel_Color
---@overload fun(a: number, r: number, g: number, b: number) : Diesel_Color
---@type table<string, Diesel_Color>
_G.Color = {
    white = Color(),
    black = Color(),
    red   = Color(),
    green = Color(),
    blue  = Color(),
    yellow = Color()
}

---@param ... string
_G.cat_error = function(...) end

---@param fn1 function
---@param fn2 function
---@return any
_G.LobbyBrowser = function(fn1, fn2) end

---@param tbl table
_G.inspect = function(tbl) end