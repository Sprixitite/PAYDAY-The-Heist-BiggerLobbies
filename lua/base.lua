---@module "meta.all"

-- Sorry this is all such a mess, it's kind of thrown together
-- I've no idea if this works or not, just throwing it on github incase
-- My progress is useful to someone else (I may still work on this in downtime)
-- Will probably move this to DSBLT first before working on it further

-- TL;DR: I'll fix it at some point (hopefully) ((maybe)) I pinkie promise

local bl_run_require = function(filePathRelativeToModRoot)
    dofile(ModPath .. '/' .. filePathRelativeToModRoot)
end

bl_run_require("lua/util/sprixlogger.lua")
bl_run_require("lua/util/sprixhookmgr.lua")

_G.bl = {
    bl_run_require = bl_run_require,
    bl_total_playable_crims = 8,
    bl_total_client_slots = function(self) return self.bl_total_playable_crims-1 end,
    bl_heisters = function(self) return {"american", "german", "russian", "spanish"} end,
    bl_additional_crims = function(self) return ( 4 * self.bl_total_playable_crims ) - 4 end,
    bl_additional_full_crims = function(self) return self.bl_total_playable_crims - 4 end,
    getLogger = function(self) return SprixHookMgr.Logger end,
    bl_name_dict = {},
    set_blname = function(self, unit, name)
        if unit == nil then return end
        if not unit:alive() then return end
        self.bl_name_dict[unit:name()] = name
    end,
    get_blname = function(self, unit)
        if unit == nil then return end
        if not unit:alive() then return end
        return self.bl_name_dict[unit:name()]
    end
}

bl.printcontext = function(context)
	local debugtext = "\nContext log for context \"" .. tostring(context) .. "\" is as follows:"
	for k, v in next, getfenv(context) do
		debugtext = debugtext .. "\n\tKey: " .. k .. "\n\t\tValue: " .. tostring(v) .. "\n\t\tType: " .. type(v)
	end
	log(debugtext)
end

bl.tabby = function(level) return string.rep('\t', level) end

bl.logtable_unfmt = function(table, level)
    level = level or 0
    for k, v in next, table do
        log(bl.tabby(level+1) .. "Key: " .. k)
        log(bl.tabby(level+2) .. "Value: " .. type(v) == "table" and bl.tbltostr(v, level+1) or tostring(v))
        log(bl.tabby(level+2) .. "Type: " .. type(v))
    end
end

bl.logtable = function(table)
    if (type(table) ~= "table") then
        log("Table printout was called on a non-table value, will try to print metatable...")
        local success, returned = blt.pcall(function()
            table = getmetatable(table)
            if type(table) == "table" then return true end
        end)
        if not ( success and returned ) then
            log("Could not get metatable, printing nothing...")
            return
        end
    end
    log("Table printout for table \"" .. tostring(table) .. "\" is as follows:")
    bl.logtable_unfmt(table)
end

return module
