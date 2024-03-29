local module = ... or D:module("BiggerLobbies")
local MenuLobbyRenderer = module:hook_class("MenuLobbyRenderer")

local mugshots = {
	random = "mugshot_random",
	undecided = "mugshot_unassigned",
	american = 1,
	german = 2,
	russian = 3,
	spanish = 4
}

local mugshot_stencil = {
	random = {
		"bg_lobby_fullteam",
		65
	},
	undecided = {
		"bg_lobby_fullteam",
		65
	},
	american = {"bg_hoxton", 80},
	german = {"bg_wolf", 55},
	russian = {"bg_dallas", 65},
	spanish = {"bg_chains", 60}
}

local heisters = bl:bl_heisters()

for i=0, bl:bl_additional_crims()-1 do

	local index = (i%4)+1
	
	local basename = heisters[index]
	local suffix = "_" .. tostring(math.floor(i/4)+2)
	
	local addname = basename .. suffix
	
	mugshots[addname] = index
	
	if basename == "american" then
		mugshot_stencil[addname] = {"bg_hoxton", 80}
	elseif basename == "german" then
		mugshot_stencil[addname] = {"bg_wolf", 55}
	elseif basename == "russian" then
		mugshot_stencil[addname] = {"bg_dallas", 65}
	else
		mugshot_stencil[addname] = {"bg_chains", 60}
	end
	
end

MenuLobbyRenderer.set_character = function(self, id, character)
	local slot = self._player_slots[id]
	slot.character:set_text(string.upper(managers.localization:text("debug_" .. character)))
	slot.character:set_color(Color.white)
	local mugshot
	if character == "random" then
		mugshot = mugshots.random
	else
		local mask_set = managers.network:session():peer(id):mask_set()
		local mask_id = mugshots[character]
		local set = tweak_data.mask_sets[mask_set][mask_id]
		mugshot = set.mask_icon
	end

	local image, rect = tweak_data.hud_icons:get_icon_data(mugshot)
	slot.mugshot:set_image(image, rect[1], rect[2], rect[3], rect[4])
	if managers.network:session():local_peer():id() == id then
		managers.menu:active_menu().renderer:set_stencil_image(mugshot_stencil[character][1])
		managers.menu:active_menu().renderer:set_stencil_align("manual", mugshot_stencil[character][2])
	end

end

MenuLobbyRenderer.open = function(self, ...)
	MenuLobbyRenderer.super.open(self, ...)
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
    local use_compact_layout = bl.bl_total_playable_crims > 16
    if use_compact_layout then self.safe_rect_panel:set_x(0) end
	self._info_bg_rect = self.safe_rect_panel:rect({
		visible = true,
		x = 0,
		y = tweak_data.load_level.upper_saferect_border,
		w = safe_rect_pixels.width * (use_compact_layout and 0.52 or 0.41),
		h = safe_rect_pixels.height - tweak_data.load_level.upper_saferect_border * 2,
		layer = -1,
		color = Color(0.5, 0, 0, 0)
	})
	self._gui_info_panel = self.safe_rect_panel:panel({
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		w = 0,
		h = 0
	})
	self._level_id = Global.game_settings.level_id
	local level_data = tweak_data.levels[self._level_id]
	self._level_video = self._gui_info_panel:video({
		video = level_data.movie,
		loop = true,
		blend_mode = "normal",
		w = self._info_bg_rect:w()*0.85,
		h = self._info_bg_rect:w()*0.85*(9/16),
		color = Color(1, 0.4, 0.4, 0.4)
	})
	managers.video:add_video(self._level_video)
	local is_server = Network:is_server()
	local server_peer = is_server and managers.network:session():local_peer() or managers.network:session():server_peer()
	local is_single_player = Global.game_settings.single_player
	local is_multiplayer = not is_single_player
	if not server_peer then
		return
	end

	local font_size = tweak_data.menu.lobby_info_font_size
	self._server_title = self._gui_info_panel:text({
		visible = is_multiplayer,
		name = "server_title",
		text = string.upper(managers.localization:text("menu_lobby_server_title")),
		font = "fonts/font_univers_530_bold",
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._server_text = self._gui_info_panel:text({
		visible = is_multiplayer,
		name = "server_text",
		text = string.upper("" .. server_peer:name()),
		font = "fonts/font_univers_530_bold",
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._server_info_title = self._gui_info_panel:text({
		visible = is_multiplayer,
		name = "server_info_title",
		text = string.upper(managers.localization:text("menu_lobby_server_state_title")),
		font = "fonts/font_univers_530_bold",
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._server_info_text = self._gui_info_panel:text({
		visible = is_multiplayer,
		name = "server_info_text",
		text = string.upper(managers.localization:text(self._server_state_string_id or "menu_lobby_server_state_in_lobby")),
		font = "fonts/font_univers_530_bold",
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._level_title = self._gui_info_panel:text({
		name = "level_title",
		text = string.upper(managers.localization:text("menu_lobby_campaign_title")),
		font = "fonts/font_univers_530_bold",
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._level_text = self._gui_info_panel:text({
		name = "level_text",
		text = string.upper("" .. managers.localization:text(level_data.name_id)),
		font = "fonts/font_univers_530_bold",
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._difficulty_title = self._gui_info_panel:text({
		name = "difficulty_title",
		text = string.upper(managers.localization:text("menu_lobby_difficulty_title")),
		font = "fonts/font_univers_530_bold",
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	self._difficulty_text = self._gui_info_panel:text({
		name = "difficulty_text",
		text = "",
		font = "fonts/font_univers_530_bold",
		color = tweak_data.hud.prime_color,
		font_size = font_size,
		align = "left",
		vertical = "center",
		w = 256,
		h = font_size,
		layer = 1
	})
	if is_server then
		self:update_level_id()
		self:update_difficulty()
	else
		self:_update_difficulty(Global.game_settings.difficulty)
	end

	self._player_slots = {}
	for i = 1, is_single_player and 1 or bl.bl_total_playable_crims do
		local t = {}
		t.player = {}
		t.free = true
		t.panel = self._gui_info_panel:panel({
			layer = 1,
			w = 256,
			h = 50 * tweak_data.scale.lobby_info_offset_multiplier,
            x = i *10,
            y = 1000000
		})
		local image, rect = tweak_data.hud_icons:get_icon_data(mugshots.undecided)
		t.mugshot = t.panel:bitmap({
			texture = image,
			texture_rect = rect,
			layer = 1
		})
		local voice_icon, voice_texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_talk")
		t.voice = t.panel:bitmap({
			name = "voice",
			texture = voice_icon,
			visible = false,
			layer = 2,
			texture_rect = voice_texture_rect,
			w = voice_texture_rect[3],
			h = voice_texture_rect[4],
			color = Color.white
		})
		t.bg_rect = self.safe_rect_panel:rect({
			visible = false,
			color = Color.white:with_alpha(0.1),
			layer = 0,
			w = 256,
			h = 42 * tweak_data.scale.lobby_info_offset_multiplier
		})
		t.name = t.panel:text({
			name = "name" .. i,
			text = string.upper(managers.localization:text("menu_lobby_player_slot_available")),
			font = "fonts/font_univers_530_bold",
			font_size = tweak_data.menu.lobby_name_font_size,
			color = Color(1, 0.5, 0.5, 0.5),
			align = "left",
			vertical = "top",
			w = 256,
			h = 24,
			layer = 1
		})
		t.character = t.panel:text({
			visible = true,
			name = "character" .. i,
			text = string.upper(managers.localization:text("debug_random")),
			font = tweak_data.hud.small_font,
			font_size = tweak_data.hud.small_font_size,
			color = Color(1, 0.5, 0.5, 0.5),
			align = "left",
			vertical = "bottom",
			w = 256,
			h = 24,
			layer = 1
		})
		t.level = t.panel:text({
			name = "level" .. i,
			visible = false,
			text = managers.localization:text("menu_lobby_level"),
			font = "fonts/font_univers_530_bold",
			font_size = tweak_data.hud.lobby_name_font_size,
			align = "right",
			vertical = "top",
			w = 256,
			h = 24,
			layer = 1
		})
		t.status = t.panel:text({
			name = "status" .. i,
			visible = true,
			text = "",
			font = tweak_data.hud.small_font,
			font_size = tweak_data.hud.small_font_size,
			align = "right",
			vertical = "bottom",
			w = 256,
			h = 24,
			layer = 1
		})
		t.frame = t.panel:polyline({
			visible = false,
			name = "frame" .. i,
			color = Color.white,
			layer = 1,
			line_width = 1,
			closed = true,
			points = {
				Vector3(),
				Vector3(10, 0, 0),
				Vector3(10, 10, 0),
				Vector3(0, 10, 0)
			}
		})
		t.kit_panel = t.panel:panel({
			visible = false,
			layer = 1,
			w = t.panel:w(),
			h = t.panel:h() / 2
		})
		t.kit_slots = {}
		for slot = 1, PlayerManager.WEAPON_SLOTS + 3 do
			local icon, texture_rect = tweak_data.hud_icons:get_icon_data("fallback")
			local kit_slot = t.kit_panel:bitmap({
				name = tostring(slot),
				texture = icon,
				layer = 0,
				texture_rect = texture_rect,
				x = 0,
				y = 0,
				w = 10,
				h = 10
			})
			table.insert(t.kit_slots, kit_slot)
		end

		t.p_panel = t.panel:panel({
			visible = false,
			layer = 0,
			w = 38,
			h = 17
		})
		t.p_bg = t.p_panel:rect({
			color = Color.black,
			layer = 0,
			w = 38,
			h = 17
		})
		t.p_ass_bg = t.p_panel:rect({
			color = Color(1, 0.5, 0.5, 0.5),
			layer = 1,
			w = 36,
			h = 3
		})
		t.p_ass = t.p_panel:rect({
			color = Color.white,
			layer = 2,
			w = 15,
			h = 3
		})
		t.p_sha_bg = t.p_panel:rect({
			color = Color(1, 0.5, 0.5, 0.5),
			layer = 1,
			w = 36,
			h = 3
		})
		t.p_sha = t.p_panel:rect({
			color = Color.white,
			layer = 2,
			w = 10,
			h = 3
		})
		t.p_sup_bg = t.p_panel:rect({
			color = Color(1, 0.5, 0.5, 0.5),
			layer = 1,
			w = 36,
			h = 3
		})
		t.p_sup = t.p_panel:rect({
			color = Color.white,
			layer = 2,
			w = 24,
			h = 3
		})
		t.p_tec_bg = t.p_panel:rect({
			color = Color(1, 0.5, 0.5, 0.5),
			layer = 1,
			w = 36,
			h = 3
		})
		t.p_tec = t.p_panel:rect({
			color = Color.white,
			layer = 2,
			w = 20,
			h = 3
		})
		table.insert(self._player_slots, t)
	end

	self:_layout_info_panel()
	self:_layout_video()
	self._menu_bg = self._main_panel:bitmap({
		texture = tweak_data.menu_themes[managers.user:get_setting("menu_theme")].background,
		layer = -3
	})
	if not self._no_stencil and not Global.load_level then
		self._menu_stencil_align = "right"
		self._menu_stencil_default_image = "guis/textures/empty"
		self._menu_stencil_image = self._menu_stencil_default_image
		self._menu_stencil = self._main_panel:bitmap({
			texture = self._menu_stencil_image,
			layer = -2,
			blend_mode = "normal"
		})
	end

	self:_entered_menu()
	MenuRenderer.setup_frames_and_logo(self)
	self:_layout_menu_bg()
end

function MenuLobbyRenderer:_layout_video()
    local size_scale = math.ceil(bl.bl_total_playable_crims / 4) > 9 and 0 or 1
	if self._level_video then
		local w = self._gui_info_panel:w() * 0.775 * size_scale
		local m = self._level_video:video_width() / self._level_video:video_height()
		self._level_video:set_size(w, w / m)
		self._level_video:set_y(0)
		self._level_video:set_x(4)
	end
end

MenuLobbyRenderer._layout_info_panel = function(self)
	local res = RenderSettings.resolution
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	local is_single_player = Global.game_settings.single_player
	local is_multiplayer = not is_single_player
	self._gui_info_panel:set_shape(self._info_bg_rect:x() + tweak_data.menu.info_padding, self._info_bg_rect:y() + tweak_data.menu.info_padding, self._info_bg_rect:w() - tweak_data.menu.info_padding * 2, self._info_bg_rect:h() - tweak_data.menu.info_padding * 2)
	local font_size = tweak_data.menu.lobby_info_font_size
	local offset = 22 * tweak_data.scale.lobby_info_offset_multiplier
	self._server_title:set_font_size(font_size)
	self._server_text:set_font_size(font_size)
	local x, y, w, h = self._server_title:text_rect()
	self._server_title:set_x(tweak_data.menu.info_padding)
	self._server_title:set_y(tweak_data.menu.info_padding)
	self._server_title:set_w(w)
	self._server_text:set_lefttop(self._server_title:righttop())
	self._server_text:set_w(self._gui_info_panel:w())
	self._server_info_title:set_font_size(font_size)
	self._server_info_text:set_font_size(font_size)
	local x, y, w, h = self._server_info_title:text_rect()
	self._server_info_title:set_x(tweak_data.menu.info_padding)
	self._server_info_title:set_y(tweak_data.menu.info_padding + offset)
	self._server_info_title:set_w(w)
	self._server_info_text:set_lefttop(self._server_info_title:righttop())
	self._server_info_text:set_w(self._gui_info_panel:w())
	self._level_title:set_font_size(font_size)
	self._level_text:set_font_size(font_size)
	local x, y, w, h = self._level_title:text_rect()
	self._level_title:set_x(tweak_data.menu.info_padding)
	self._level_title:set_y(is_multiplayer and tweak_data.menu.info_padding + offset * 2 or tweak_data.menu.info_padding)
	self._level_title:set_w(w)
	self._level_text:set_lefttop(self._level_title:righttop())
	self._level_text:set_w(self._gui_info_panel:w())
	self._difficulty_title:set_font_size(font_size)
	self._difficulty_text:set_font_size(font_size)
	local x, y, w, h = self._difficulty_title:text_rect()
	self._difficulty_title:set_x(tweak_data.menu.info_padding)
	self._difficulty_title:set_y(tweak_data.menu.info_padding + offset * (is_multiplayer and 3 or 1))
	self._difficulty_title:set_w(w)
	self._difficulty_text:set_lefttop(self._difficulty_title:righttop())
	self._difficulty_text:set_w(self._gui_info_panel:w())

    local per_column = bl.bl_total_playable_crims / 8 <= 4 and 8 or math.ceil(bl.bl_total_playable_crims/4)
    local groups = math.ceil(bl.bl_total_playable_crims/per_column)
    local use_compact_layout = groups > 3
    local mugshot_shrink_factor = 2

	local pad = (use_compact_layout and 0 or 3) * tweak_data.scale.lobby_info_offset_multiplier
	for i, slot in ipairs(self._player_slots) do

        local i_column = math.floor((i-1)/per_column)
        local column_width = slot.panel:parent():w()/groups
        local extra = self._info_bg_rect:w()-column_width*groups

		slot.panel:set_h(50 * tweak_data.scale.lobby_info_offset_multiplier)
		slot.panel:set_w(column_width)
        slot.panel:set_x(column_width*i_column)
		slot.panel:set_bottom(self._gui_info_panel:h() - ((bl.bl_total_playable_crims - i)%per_column) * slot.panel:h())
		if slot.params then
			self:_layout_slot_progress_panel(slot, slot.params.progress)
		end

        if not use_compact_layout then
            slot.mugshot:set_size(slot.panel:h() - pad, slot.panel:h() - pad)
            slot.mugshot:set_x(0)
            slot.mugshot:set_center_y(slot.panel:h() / 2)
        else
            slot.mugshot:set_size(slot.panel:h()/mugshot_shrink_factor - pad, slot.panel:h()/mugshot_shrink_factor - pad)
            slot.mugshot:set_x(0)
            slot.mugshot:set_y(0)
        end
		
		slot.voice:set_righttop(slot.mugshot:righttop())
		local x, y, w, h = slot.level:text_rect()
		slot.level:set_w(100)
		slot.bg_rect:set_position(slot.panel:x(), 0)
		slot.bg_rect:set_size(column_width+extra, slot.panel:h())
		slot.bg_rect:set_position(self._info_bg_rect:x(), self._gui_info_panel:y() + slot.panel:y())
		slot.name:set_font_size(tweak_data.menu.lobby_name_font_size)
		slot.name:set_lefttop(slot.mugshot:w() + pad, pad)
		slot.level:set_top(0 + pad)
		slot.p_panel:set_w((use_compact_layout and 19 or 38) * tweak_data.scale.lobby_info_offset_multiplier)
		slot.p_panel:set_top(slot.level:top())
		slot.p_panel:set_right(slot.p_panel:parent():w())
		slot.level:set_font_size(tweak_data.menu.lobby_name_font_size)
		slot.level:set_right(slot.p_panel:left() - pad)
		slot.status:set_font_size(tweak_data.menu.small_font_size)
		slot.status:set_right(slot.panel:w() - pad)
		slot.status:set_bottom(slot.panel:h() - pad)
		slot.character:set_font_size(tweak_data.menu.small_font_size)
		slot.character:set_leftbottom(slot.mugshot:w() + pad, slot.panel:h() - pad)
		local bg = slot.bg_rect
		slot.frame:set_points({
			Vector3(bg:left(), bg:top(), 0),
			Vector3(bg:right(), bg:top(), 0),
			Vector3(bg:right(), bg:bottom(), 0),
			Vector3(bg:left(), bg:bottom(), 0)
		})
		slot.kit_panel:set_w(slot.panel:w() - slot.mugshot:w() - pad)
		slot.kit_panel:set_h(slot.panel:h() / 2 - pad)
		slot.kit_panel:set_x( (not use_compact_layout and slot.mugshot:w() or 0) + pad)
		slot.kit_panel:set_y(slot.panel:h() / 2)
		for i, kit_slot in ipairs(slot.kit_slots) do
			kit_slot:set_size(slot.kit_panel:h(), slot.kit_panel:h())
			kit_slot:set_position(slot.kit_panel:h() * (i - 1), 0)
		end

	end

end
