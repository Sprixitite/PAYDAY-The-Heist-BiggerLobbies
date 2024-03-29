local module = ... or D:module("BiggerLobbies")
local GroupAIStateBase = module:hook_class("GroupAIStateBase")

GroupAIStateBase.on_criminal_team_AI_enabled_state_changed = function(self)
	if Network:is_client() then
		return
	end

	if Global.criminal_team_AI_disabled then
		for i = 1, bl:bl_total_client_slots() do
			self:remove_one_teamAI()
		end

	else
		self:fill_criminal_team_with_AI()
	end

end

GroupAIStateBase.fill_criminal_team_with_AI = function(self, is_drop_in)

	while true do
	
		if not managers.criminals:get_free_character_name(true) or not self:spawn_one_teamAI(is_drop_in) then
			break
		end

	end

end

-- GroupAIStateBase.amount_of_winning_ai_criminals = function(self)
-- 	local amount = 0
-- 	for k, u_data in next, self._ai_criminals do
-- 		if alive(u_data.unit) and not u_data.unit:character_damage():bleed_out() and not u_data.unit:character_damage():fatal() and not u_data.unit:character_damage():arrested() and not u_data.unit:character_damage():dead() then
-- 			amount = amount + 1
-- 		end

-- 	end
	
-- 	amount = math.max(0, math.min( amount, 4 - #self:all_player_criminals() ))

-- 	return amount
-- end

GroupAIStateBase.spawn_one_teamAI = function(self, is_drop_in, char_name, spawn_on_unit)
    local logger = bl:getLogger()

    logger:beginScope("spawn_one_teamAI")

	if Global.criminal_team_AI_disabled or not self._ai_enabled then
        logger:endScope()
		return
	end

	local objective = self:_determine_spawn_objective_for_criminal_AI()
	if objective and objective.type == "follow" then
		local player = spawn_on_unit or objective.follow_unit
		local player_pos = player:position()
		local tracker = player:movement():nav_tracker()
		local spawn_pos, spawn_rot
		if is_drop_in or spawn_on_unit then
			local spawn_fwd = player:movement():m_head_rot():y()
			mvector3.set_z(spawn_fwd, 0)
			mvector3.normalize(spawn_fwd)
			spawn_rot = Rotation(spawn_fwd, math.UP)
			spawn_pos = player_pos
			if not tracker:lost() then
				local search_pos = player_pos - spawn_fwd * 200
				local ray_params = {
					tracker_from = tracker,
					allow_entry = false,
					pos_to = search_pos,
					trace = true
				}
				local ray_hit = managers.navigation:raycast(ray_params)
				if ray_hit then
					spawn_pos = ray_params.trace[1]
				else
					spawn_pos = search_pos
				end

			end

		else
			local spawn_point = managers.network:game():get_next_spawn_point()
			spawn_pos = spawn_point.pos_rot[1]
			spawn_rot = spawn_point.pos_rot[2]
			objective.in_place = true
		end

		local character_name = char_name or managers.criminals:get_free_character_name(true)
		local unit_char_name = character_name:gsub("_.*", "")
        
		local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
		local unit_folder = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
		local unit_name = Idstring("units/characters/npc/criminal/" .. unit_folder .. "/" .. unit_char_name .. "_npc")
		local unit = World:spawn_unit(unit_name, spawn_pos, spawn_rot)
		
        logger:log("Set unit's _blname to \"" .. character_name .. "\"")
        _G.bl:set_blname(unit, character_name)
		
		managers.network:session():send_to_peers_synched("set_unit", unit, character_name, 0)
		if char_name and not is_drop_in then
			managers.criminals:set_unit(character_name, unit)
		else
			managers.criminals:add_character(character_name, unit, nil, true)
		end

		unit:movement():set_character_anim_variables()
		unit:brain():set_spawn_ai({
			init_state = "idle",
			params = {scan = true},
			objective = objective
		})

        logger:endScope()

		return unit
	end

end
