---@enum Sprix_LogHeadingType
local HEADING_TYPES = {
    BEGIN_SCOPE     = 1,
    END_SCOPE       = 2,
    INTERRUPT_SCOPE = 3
}

local CONFIG = {
    INDENT_AMT = string.rep(' ', 2),

    SCOPE_HEADING_DENOTE = "[]",
    SCOPE_SYMBOLS = {
        [ HEADING_TYPES.BEGIN_SCOPE     ] = '+',
        [ HEADING_TYPES.END_SCOPE       ] = '-',
        [ HEADING_TYPES.INTERRUPT_SCOPE ] = '!',
    },
}

local function indent_by(amt)
    amt = math.max(amt, 0)
    return string.rep(CONFIG.INDENT_AMT, amt)
end

---@param hType Sprix_LogHeadingType
---@param name string
---@return string
local function scope_heading(hType, name)
    local left = CONFIG.SCOPE_HEADING_DENOTE:sub(1, #CONFIG.SCOPE_HEADING_DENOTE * 0.5)
    local right = CONFIG.SCOPE_HEADING_DENOTE:sub((#CONFIG.SCOPE_HEADING_DENOTE * 0.5)+1, -1) -- dang 1 indexing

    local symb = CONFIG.SCOPE_SYMBOLS[hType]
    
    return table.concat({ left, symb, name, right }, ' ')
end

---@alias Sprix_LogFunc fun(msg: string)

---@class Sprix_LogObj
---@field new        fun(logFunc: Sprix_LogFunc) : Sprix_LogObj
---@field log           fun(self: Sprix_LogObj, ...: string)
---@field interrupt_log fun(self: Sprix_LogObj, interrupt_scope: string, ...: string)
---@field private beginScope fun(self: Sprix_LogObj, scopeName: string)
---@field private endScope   fun(self: Sprix_LogObj)
---@field private scopeStack string[]
---@field private logFunc Sprix_LogFunc
local sprixLogger = {}
sprixLogger.__index = sprixLogger

function sprixLogger.new(optionalLogFunc)
    optionalLogFunc = optionalLogFunc or print

    local newSprixLogger = {
        scopeStack = {},
        logFunc = optionalLogFunc
    }

    setmetatable(newSprixLogger, sprixLogger)

    return newSprixLogger
end

local function CurrentScope(sprixLogger)
    return sprixLogger.scopeStack[#sprixLogger.scopeStack]
end

function sprixLogger:beginScope(scopeName)
    self:log(scope_heading( HEADING_TYPES.BEGIN_SCOPE, scopeName ))
    table.insert(self.scopeStack, scopeName)
end

function sprixLogger:log(...)
    local indent = indent_by(#self.scopeStack)

    local msg_t = {}
    local n = select('#', ...)
    for i=1, n do
        msg_t[i] = tostring(select(i, ...))
    end
    local msg = indent .. table.concat(msg_t, " // ")

    self.logFunc(msg)
end

function sprixLogger:interrupt_log(interrupt_scope, ...)
    local indent = indent_by(#self.scopeStack - 1)

    self.logFunc(indent .. scope_heading(HEADING_TYPES.INTERRUPT_SCOPE, interrupt_scope))
    self:log(...)
end

function sprixLogger:endScope()
    if #self.scopeStack == 0 then
        self:log("Attempt to close nonexistent scope!", false)
        return
    end
    local ending = CurrentScope(self)
    table.remove(self.scopeStack, #self.scopeStack)
    self:log( scope_heading( HEADING_TYPES.END_SCOPE, ending ) )
end

---@generic FunT : function
---@param self Sprix_LogObj
---@param name string
---@param fn FunT
---@return FunT
function sprixLogger:wrap(name, debugging, fn)
    return function(...)
        self:beginScope(name)
        local results = { blt.pcall(fn, ...) }
        local success = results[1]
        if not success then
            local failReason = results[2]
            self:interrupt_log(name .. "->ERROR", failReason)
            if debugging then
                error("Function \"" .. name .. "\" failed with reason \"" .. failReason .. "\"!")
            end
        elseif success and debugging then
            self:interrupt_log(name .. "->SUCCESS", "Ran successfully!")
        end
        self:endScope()
        return unpack(results, 2)
    end
end

_G.SprixLogger = sprixLogger