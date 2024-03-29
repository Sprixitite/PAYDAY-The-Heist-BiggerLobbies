local module = ... or D:module("BiggerLobbies")
local NetworkMember = module:hook_class("NetworkMember")

NetworkMember.spawn_unit = function(self, spawn_point_id, is_drop_in, spawn_as)

    local logger = bl:getLogger()

    logger:beginScope("spawn_unit")

	if self._unit then
        logger:endScope()
		return
	end

	if not self._peer:synched() then
        logger:endScope()
		return
	end

	local peer_id = self._peer:id()
	self._spawn_unit_called = true
	local pos_rot
	if is_drop_in then
		local spawn_on
		if Global.local_member and alive(Global.local_member:unit()) then
			spawn_on = Global.local_member:unit()
		end

		if not spawn_on then
			local u_key, u_data = next(managers.groupai:state():all_char_criminals())
			if u_data and alive(u_data.unit) then
				spawn_on = u_data.unit
			end

		end

		if spawn_on then
			local pos = spawn_on:position()
			local rot = spawn_on:rotation()
			pos_rot = {pos, rot}
		else
			local spawn_point = managers.network:game():get_next_spawn_point() or managers.network:spawn_point(1)
			pos_rot = spawn_point.pos_rot
		end

	else
		pos_rot = managers.network:spawn_point(spawn_point_id).pos_rot
	end

	local member_downed, member_dead, health, used_deployable = self:_get_old_entry()
	local character_name, trade_entry, need_revive, need_res
	
	-- Temporary, need to make something to unmix characters at some point
	-- E.g: "american" is already taken, move to "american_2"
	-- Issue is more than 2 x dallas would crash, but adding 8 character references for each character would spawn 63 bots
	--character_name = managers.criminals:get_free_character_name()
	
	if self._assigned_name then
		print("[NetworkMember:spawn_unit] Member assigned as", self._assigned_name)
		local old_unit
		trade_entry, old_unit = managers.groupai:state():remove_one_teamAI(self._assigned_name, member_dead)
		if trade_entry and member_dead then
			trade_entry.peer_id = peer_id
		end

		character_name = managers.criminals:upgrade_crimname_to_contingent(self._assigned_name)
		self._assigned_name = nil
		need_revive = not alive(old_unit) or old_unit:character_damage():bleed_out() or old_unit:character_damage():fatal() or old_unit:character_damage():arrested() or old_unit:character_damage():need_revive() or old_unit:character_damage():dead()
		need_revive = need_revive or Global.criminal_team_AI_disabled or not managers.groupai:state():is_AI_enabled()
		need_res = trade_entry and true or Global.criminal_team_AI_disabled or true
	else
		character_name = managers.criminals:character_name_by_peer_id(peer_id)
		if not character_name then
			if spawn_as then
				character_name = managers.criminals:upgrade_crimname_to_contingent(spawn_as)
			else
				character_name = managers.criminals:get_free_character_name()
			end

			if not character_name then
				cat_error("multiplayer_base", "[NetworkMember:spawn_unit] failed to find available character name for peer", peer_id)
                logger:endScope()
				return
			end

		end

	end
	
    -- logger:log("Crimname pre-upgrade: " .. character_name)
	-- character_name = managers.criminals:upgrade_crimname_to_contingent(character_name)
    -- logger:log("Crimname post-upgrade: " .. character_name)

	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_name_suffix = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
	local unit_name = Idstring("units/multiplayer/mp_fps_mover/mp_fps_mover_" .. unit_name_suffix)
	local unit
	if self == Global.local_member then
		unit = World:spawn_unit(unit_name, pos_rot[1], pos_rot[2])
	else
		unit = Network:spawn_unit_on_client(self._peer:rpc(), unit_name, pos_rot[1], pos_rot[2])
	end
	
    logger:log("Set unit's _blname to \"" .. character_name .. "\"")
	_G.bl:set_blname(unit, character_name)

	self:set_unit(unit, character_name)
	managers.network:session():send_to_peers_synched("set_unit", unit, character_name, peer_id)
	if is_drop_in then
		self._peer:set_used_deployable(used_deployable)
		self._peer:send_queued_sync("spawn_dropin_penalty", (need_res or need_revive) and member_dead, (need_res or need_revive) and member_downed, health, used_deployable)
	end

    logger:endScope()
	return unit
end

NetworkMember.set_unit = function(self, unit, character_name)

    local logger = bl:getLogger()
    logger:beginScope("set_unit")

	local is_new_unit = unit and (not self._unit or self._unit:key() ~= unit:key())

    _G.bl:set_blname(unit, character_name)
    logger:log("Set unit's _blname to \"" .. character_name .. "\"")

	self._unit = unit
	if is_new_unit and self == Global.local_member then
		managers.player:spawned_player(1, unit)
	end

	if unit then
		if not managers.criminals:character_name_by_peer_id(self._peer:id()) then
			managers.criminals:add_character(character_name, unit, self._peer:id(), false)
		else
			managers.criminals:set_unit(character_name, unit)
		end

	end

	if is_new_unit then
		unit:movement():set_character_anim_variables()
		if self ~= Global.local_member then
			managers.player:update_crew_bonus_enabled(self._peer:id(), unit:movement():current_state_name())
		end

	end

    logger:endScope()

end
