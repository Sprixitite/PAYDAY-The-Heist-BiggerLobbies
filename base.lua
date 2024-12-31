local module = DMod:new("BiggerLobbies", {
	abbr = "BL",
	version = "0.1",
	author = "Sprixitite",
	description = "Probably won't work",
})

-- Sorry this is all such a mess, it's kind of thrown together
-- I've no idea if this works or not, just throwing it on github incase
-- My progress is useful to someone else (I may still work on this in downtime)
-- Will probably move this to DSBLT first before working on it further

-- TL;DR: I'll fix it at some point (hopefully) ((maybe)) I pinkie promise

module:register_include("sprixLogger")

_G.bl = {
    bl_total_playable_crims = 8,
    bl_total_client_slots = function(self) return self.bl_total_playable_crims-1 end,
    bl_heisters = function(self) return {"american", "german", "russian", "spanish"} end,
    bl_additional_crims = function(self) return ( 4 * self.bl_total_playable_crims ) - 4 end,
    bl_additional_full_crims = function(self) return self.bl_total_playable_crims - 4 end,
    getLogger = function(self)
        if self.logger == nil then
            self.logger = sprixLogger.new(dorhud_log)
        end
        return self.logger
    end,
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
	dorhud_log(debugtext)
end

bl.tabby = function(level) return string.rep('\t', level) end

bl.logtable_unfmt = function(table, level)
    level = level or 0
    for k, v in next, table do
        dorhud_log(bl.tabby(level+1) .. "Key: " .. k)
        dorhud_log(bl.tabby(level+2) .. "Value: " .. type(v) == "table" and bl.tbltostr(v, level+1) or tostring(v))
        dorhud_log(bl.tabby(level+2) .. "Type: " .. type(v))
    end
end

bl.logtable = function(table)
    if (type(table) ~= "table") then
        dorhud_log("Table printout was called on a non-table value, will try to print metatable...")
        local success, returned = pcall(function()
            table = getmetatable(table)
            if type(table) == "table" then return true end
        end)
        if not ( success and returned ) then
            dorhud_log("Could not get metatable, printing nothing...")
            return
        end
    end
    dorhud_log("Table printout for table \"" .. tostring(table) .. "\" is as follows:")
    bl.logtable_unfmt(table)
end

module:hook_post_require("lib/managers/criminalsmanager",                           "criminalsmanager"          )
module:hook_post_require("lib/managers/mission/elementmissionend",                  "elementmissionend"         )
module:hook_post_require("lib/managers/group_ai_states/groupaistatebase",           "groupaistatebase"          )
module:hook_post_require("lib/network/base/hostnetworksession",                     "hostnetworksession"        )
module:hook_post_require("lib/network/base/session_states/hoststateinlobby",        "hoststateinlobby"          )
module:hook_post_require("lib/managers/hudmanager",                                 "hudmanager"                )
module:hook_post_require("lib/network/extensions/player/huskplayermovement",        "huskplayermovement"        )
module:hook_post_require("lib/managers/menu/menulobbyrenderer",                     "menulobbyrenderer"         )
module:hook_post_require("lib/managers/menu/menunodegui",                           "menunodegui"               )
module:hook_post_require("lib/network/networkgame",                                 "networkgame"               )
module:hook_post_require("lib/network/base/networkmanager",                         "networkmanager"            )
module:hook_post_require("lib/network/matchmaking/networkmatchmakingsteam",         "networkmatchmakingsteam"   )
module:hook_post_require("lib/network/networkmember",                               "networkmember"             )
module:hook_post_require("lib/managers/playermanager",                              "playermanager"             )
module:hook_post_require("lib/units/beings/player/playermovement",                  "playermovement"            )

return module
