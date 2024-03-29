local module = ... or D:module("BiggerLobbies")
local CriminalsManager = module:hook_class("CriminalsManager")

module:post_hook(CriminalsManager, "init", function(self)
    local ref_tbl = {}
    for k, v in pairs(self._characters) do
        ref_tbl[v.name] = v.static_data
        v._bl_is_contingency = false
    end
    
    local additional_full_crims = bl:bl_additional_full_crims()
    -- Start at base 0 and offset after to make maths easier
    for i=0, bl:bl_additional_crims()-1 do
        local heisters = bl:bl_heisters()
        -- Tables starting at 1 is such a bitch sometimes
        local basename = heisters[(i % 4)+1]
        local suffix = "_" .. tostring(math.floor(i/4)+2)
        table.insert(self._characters, {
            taken = false,
            name = basename .. suffix,
            unit = nil,
            peer_id = 0,
            static_data = ref_tbl[basename],
            data = {},
            _bl_is_contingency = ( i >= additional_full_crims )
        })
    end
end)

CriminalsManager.character_data_by_name = function(self, name)
    for k, data in next, self._characters do
        if name == data.name then
            return data.data
        end

    end

end

CriminalsManager.character_name_by_unit = function(self, unit)

    local logger = bl:getLogger()

    logger:beginScope("character_name_by_unit")

    if type_name(unit) ~= "Unit" then
        logger:log("Passed \"unit\" was not a unit")
        logger:endScope()
        return nil
    end
    --bl.logtable(unit)

    local returned = _G.bl:get_blname(unit)
    local success = returned ~= nil
        
    if success then
        logger:log("Successfully found the unit\'s _blname \"" .. returned .. "\"")
        logger:endScope()
        return returned
    end

    local search_key = unit:key()
    for k, data in next, self._characters do
        if data.unit and data.taken and search_key == data.unit:key() then
            logger:log("No _blname found belonging to unit, returning unused name \"" .. data.name .. "\"")
            logger:endScope()
            return data.name
        end

    end

end

--[[CriminalsManager.is_taken = function(self, name)
    local original_taken = false
    for k, character in pairs(self._characters) do
        if name != character.name then continue end
        if not character.taken then
            return false
        elseif character.taken then
            if original_taken then return true end
            else original_taken = true end
        end
    end

    dorhud_log("dhauihdrfishijas")
    dorhud_log(debug.traceback())

    return false
end]]

--[[module:post_hook(CriminalsManager, "add_character", function(self, name, unit, peer_id, ai)
    for k, character in pairs(self._characters) do
        if character.name == name then
            character.taken = false
        end
    end
end)]]

CriminalsManager.getchar = function(self, crimname)
    for k, char in next, self._characters do
        if char.name == crimname then return char end
    end
end

CriminalsManager.chartaken = function(self, char)
    local taken = char.taken or managers.groupai:state():is_teamAI_marked_for_removal(char.name)
    if not taken then
        for k, member in next, managers.network:game():all_members() do
            if member._assigned_name == char.name then
                taken = true
            end
        end

    end
end

CriminalsManager.upgrade_crimname_to_contingent = function( self, crimname )

    for i=1, (bl.bl_total_playable_crims / 4)-2 do
    
        local contingentname = i==1 and crimname or crimname .. "_" .. tostring(i)
        
        local contingentchar = self:getchar(contingentname)
        
        local contingenttaken = self:chartaken(contingentchar)
        
        if not contingenttaken then return contingentname end
    
    end
    
    return crimname .. "_" .. tostring((bl.bl_total_playable_crims / 4)-1)

end

CriminalsManager.get_free_character_name = function(self, refusecontingent)
    
    -- Used to avoid spawning contingents in functions like "fill_criminal_team_with_AI"
    refusecontingent = refusecontingent or false
    
    local free = {}
    
    for k, character in next, self._characters do
        if not character._bl_is_contingency then
    
            local taken = character.taken or managers.groupai:state():is_teamAI_marked_for_removal(character.name)
            if not taken then
                for k, member in next, managers.network:game():all_members() do
                    if member._assigned_name == character.name then
                        taken = true
                    end
                end

            end
            
            if not taken then free[#free+1] = character.name end
            
        end
    end
    
    if refusecontingent and #free == 0 then return nil end
    
    -- Prefer non-contingent characters
    -- If no non-contingent characters are available, return a random contingent
    if #free == 0 then
        return self:upgrade_crimname_to_contingent( bl:bl_heisters()[math.random(1,4)] )
    else
        return free[math.random(1, #free)]
    end

end


