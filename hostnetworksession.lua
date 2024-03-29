local module = ... or D:module("BiggerLobbies")
local HostNetworkSession = module:hook_class("HostNetworkSession")

HostNetworkSession.chk_server_joinable_state = function(self)
    for peer_id, peer in next, self._peers do
        if peer:force_open_lobby_state() then
            print("force-opening lobby for peer", peer_id)
            managers.network.matchmake:set_server_joinable(true)
            return
        end
    end

	if table.size(self._peers) >= bl:bl_total_client_slots() then
		managers.network.matchmake:set_server_joinable(false)
		return
	end

	local game_state_name = game_state_machine:last_queued_state_name()
	if BaseNetworkHandler._gamestate_filter.any_end_game[game_state_name] then
		managers.network.matchmake:set_server_joinable(false)
		return
	end

	if not self:_get_free_client_id() then
		managers.network.matchmake:set_server_joinable(false)
		return
	end

	if not self._state:is_joinable(self._state_data) then
		managers.network.matchmake:set_server_joinable(false)
		return
	end

	if NetworkManager.DROPIN_ENABLED then
		if BaseNetworkHandler._gamestate_filter.lobby[game_state_name] then
			managers.network.matchmake:set_server_joinable(true)
			return
		elseif managers.groupai and not managers.groupai:state():chk_allow_drop_in() then
			managers.network.matchmake:set_server_joinable(false)
			return
		end

	elseif not BaseNetworkHandler._gamestate_filter.lobby[game_state_name] then
		managers.network.matchmake:set_server_joinable(false)
		return
	end

	managers.network.matchmake:set_server_joinable(true)
end

HostNetworkSession._get_free_client_id = function(self)
	local i = 2
    while i < bl.bl_total_playable_crims+1 do

		if not self._peers[i] then
			local is_dirty = false

            for peer_id, peer in next, self._peers do
                if peer:handshakes()[i] then
                    is_dirty = true
                end
			end

			if not is_dirty then
				return i
			end

		end

		i = i + 1
	end
end