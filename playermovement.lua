local module = ... or D:module("BiggerLobbies")
local PlayerMovement = module:hook_class("PlayerMovement")

PlayerMovement.set_character_anim_variables = function(self)

    local logger = bl:getLogger()
    logger:beginScope("set_character_anim_variables")

	local char_name = managers.criminals:character_name_by_unit(self._unit)
	local mesh_names = {}
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_suit = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	if not lvl_tweak_data then
		for k, char in next, managers.criminals._characters do
			mesh_names[char.name] = ""
		end
	elseif unit_suit == "cat_suit" or managers.player._player_mesh_suffix == "_scrubs" then
		for k, char in next, managers.criminals._characters do
			if char.static_data.ssuffix == "b" then
				mesh_names[char.name] = "_chains"
			else
				mesh_names[char.name] = ""
			end
		end
	else
		for k, char in next, managers.criminals._characters do
			if char.static_data.ssuffix == "b" then mesh_names[char.name] = "_chains"
			elseif char.static_data.ssuffix == "d" then mesh_names[char.name] = "_hoxton"
			elseif char.static_data.ssuffix == "a" then mesh_names[char.name] = "_dallas"
			else mesh_names[char.name] = "" end
		end
	end
	
	for k, v in next, mesh_names do
		logger:log("Key: " .. k .. " Value: \"" .. tostring(v) .. "\"")
	end

    logger:log("char_name: " .. tostring(char_name))
	logger:log("mesh_names[char_name] exists: " .. tostring(mesh_names[char_name] ~= nil))
	logger:log("player_mesh_suffix exists: " .. tostring(managers.player._player_mesh_suffix ~= nil))

    local success, _ = pcall(function()
	local mesh_name = Idstring("g_fps_hand" .. mesh_names[char_name] .. managers.player._player_mesh_suffix)
	local mesh_obj = self._unit:camera():camera_unit():get_object(mesh_name)
	if mesh_obj then
		if self._plr_mesh_name then
			local old_mesh_obj = self._unit:camera():camera_unit():get_object(self._plr_mesh_name)
			if old_mesh_obj then
				old_mesh_obj:set_visibility(false)
			end

		end

		self._plr_mesh_name = mesh_name
		mesh_obj:set_visibility(true)
	end
    end)

    if not success then
        logger:log(debug.traceback())
        error()
    end

    logger:endScope()

end
