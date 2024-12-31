local module = ... or D:module("BiggerLobbies")
local NetworkMatchMakingSTEAM = module:hook_class("NetworkMatchMakingSTEAM")

-- Code snippet from BL3
NetworkMatchMakingSTEAM.OPEN_SLOTS = bl.bl_total_playable_crims

local currentKey = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = currentKey and currentKey .. "_biggerlobbies" or "biggerlobbies"

module:post_hook(NetworkMatchMakingSTEAM, "init", function(self)
    self.OPEN_SLOTS = bl.bl_total_playable_crims;
end, false)

NetworkMatchMakingSTEAM.create_lobby = function(self, settings)
	self._num_players = nil
	local dialog_data = {}
	dialog_data.title = managers.localization:text("dialog_creating_lobby_title")
	dialog_data.text = managers.localization:text("dialog_wait")
	dialog_data.id = "create_lobby"
	dialog_data.no_buttons = true
	managers.system_menu:show(dialog_data)
	local function f(result, handler)
		print("Create lobby callback!!", result, handler)
		if result == "success" then
			self.lobby_handler = handler
			self:set_attributes(settings)
			self.lobby_handler:publish_server_details()
			self.lobby_handler:set_joinable(true)
			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
			managers.system_menu:close("create_lobby")
			managers.menu:created_lobby()
		else
			managers.system_menu:close("create_lobby")
			local title = managers.localization:text("dialog_error_title")
			local dialog_data = {
				title = title,
				text = managers.localization:text("dialog_err_failed_creating_lobby")
			}
			dialog_data.button_list = {
				{
					text = managers.localization:text("dialog_ok")
				}
			}
			managers.system_menu:show(dialog_data)
		end

	end

	return Steam:create_lobby(f, --[[ previously "self.OPEN_SLOTS" ]] bl.bl_total_playable_crims, "invisible")
end

NetworkMatchMakingSTEAM.search_lobby = function(self, friends_only)
	self._search_friends_only = friends_only
	if not self:_has_callback("search_lobby") then
		return
	end

	managers.menu:show_retrieving_servers_dialog()
	if friends_only then
		self:get_friends_lobbies()
	else
		---@return nil
		local function refresh_lobby()
			local lobbies = self.browser:lobbies()
			local info = {
				room_list = {},
				attribute_list = {}
			}
			print("on_match")
			if lobbies then
				print(inspect(lobbies))
				for k, lobby in ipairs(lobbies) do
					if self._difficulty_filter == 0 or self._difficulty_filter == tonumber(lobby:key_value("difficulty")) then
						print("Found lobby ", lobby:id(), lobby:key_value("owner_name"), lobby:key_value("owner_id"), lobby:member_limit(), lobby:num_members())
						table.insert(info.room_list, {
							owner_id = lobby:key_value("owner_id"),
							owner_name = lobby:key_value("owner_name"),
							room_id = lobby:id()
						})
						table.insert(info.attribute_list, {
							numbers = self:_lobby_to_numbers(lobby)
						})
					end

				end

			end

			self:_call_callback("search_lobby", info)
		end

		-- Create the browser? Don't know what the "refresh_lobby, refresh_lobby" is about
		self.browser = LobbyBrowser(refresh_lobby, refresh_lobby)

		-- Filters we care about?
		local interest_keys = {
			"owner_id",
			"owner_name",
			"level",
			"difficulty",
			"permission",
			"state",
			"drop_in",
			"min_level"
		}

		-- ? No idea ?
		if self._BUILD_SEARCH_INTEREST_KEY then
			table.insert(interest_keys, self._BUILD_SEARCH_INTEREST_KEY)
		end

		-- Set all non-distance filters ( declared above )
		self.browser:set_interest_keys(interest_keys)

		-- Set distance filter
		self.browser:set_distance_filter(self._distance_filter)
		if Global.game_settings.playing_lan then
			-- Search for lobbies over the local network
			self.browser:refresh_lan()
		else
			-- Search for lobbies over the internet
			self.browser:refresh()
		end

	end

end
