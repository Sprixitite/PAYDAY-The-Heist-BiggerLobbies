local module = ... or D:module("BiggerLobbies")

-- I think this is the third bit of logging code I've written so far
-- There's a lot of dead code lying about here

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
    self:log("BeginScope " .. scopeName)
    table.insert(self.scopeStack, scopeName)
end

function sprixLogger:log(toLog, optionalRespectScope)
    optionalRespectScope = optionalRespectScope or true

    local scope = optionalRespectScope and #self.scopeStack or 0
    local indent = string.rep("  ", scope)

    self.logFunc(indent .. toLog)
end

function sprixLogger:endScope()
    if #self.scopeStack == 0 then
        self:log("Attempt to close nonexistent scope!", false)
        return
    end
    local ending = CurrentScope(self)
    table.remove(self.scopeStack, #self.scopeStack)
    self:log("EndScope " .. ending)
end

_G.sprixLogger = sprixLogger