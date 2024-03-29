local module = ... or D:module("BiggerLobbies")
local NetworkGame = module:hook_class("NetworkGame")

NetworkGame.on_peer_request_character = function(self, peer_id, character)

	local finalname = character

	if character ~= "random" then
	
		local basename = character
		local i = 1
		for k, member in next, self._members do
			finalname = i > 1 and basename .. "_" .. tostring(i) or basename
			if member:peer():character() == finalname then
				i = i+1
			end

		end

	end

	dorhud_log("on_peer_request_character: upgraded name \"" .. character .. "\" to \"" .. finalname .. "\"")

	if Global.game_settings.single_player then
		local peer = managers.network:session():peer(peer_id)
		peer:set_character(finalname)
		local lobby_menu = managers.menu:get_menu("lobby_menu")
		if lobby_menu and lobby_menu.renderer:is_open() then
			lobby_menu.renderer:set_character(peer_id, finalname)
		end

		local kit_menu = managers.menu:get_menu("kit_menu")
		if kit_menu and kit_menu.renderer:is_open() then
			kit_menu.renderer:set_character(peer_id, finalname)
		end

		return
	end

	if not managers.network:session():local_peer():in_lobby() then
	end

	print("[NetworkGame:on_peer_request_character] peer", peer_id, "character", character)
	managers.network:session():peer(peer_id):set_character(finalname)
	local lobby_menu = managers.menu:get_menu("lobby_menu")
	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:set_character(peer_id, finalname)
	end

	local kit_menu = managers.menu:get_menu("kit_menu")
	if kit_menu and kit_menu.renderer:is_open() then
		kit_menu.renderer:set_character(peer_id, finalname)
	end

	managers.network:session():send_to_peers("request_character_response", peer_id, finalname)
end
