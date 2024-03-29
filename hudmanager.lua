local module = ... or D:module("BiggerLobbies")
local HUDManager = module:hook_class("HUDManager")

function HUDManager:add_mugshot_by_unit(unit)
	if unit:base().is_local_player then
		return
	end

	local character_name = unit:base():nick_name()
	local name_label_id = managers.hud:_add_name_label({name = character_name, unit = unit})
	unit:unit_data().name_label_id = name_label_id
	local is_husk_player = unit:base().is_husk_player
	local location_id = unit:movement().get_location_id and unit:movement():get_location_id()
	local location_text = string.upper(location_id and managers.localization:text(location_id) or "")
	local character_name_id = managers.criminals:character_name_by_unit(unit)
		for i, data in ipairs(self._hud.mugshots) do
			if data.character_name_id == character_name_id then
				if is_husk_player and not data.peer_id then
					self:_remove_mugshot(data.id)
					break
				else
					unit:unit_data().mugshot_id = data.id
					managers.hud:set_mugshot_normal(unit:unit_data().mugshot_id)
					managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, 1)
					managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, 1)
					managers.hud:set_mugshot_location(unit:unit_data().mugshot_id, location_id)
					return
				end

		end

	end

	local crew_bonus, peer_id
	if is_husk_player then
		peer_id = unit:network():peer():id()
		crew_bonus = managers.player:get_crew_bonus_by_peer(peer_id)
	end

	dorhud_log("character_name_id: " .. tostring(character_name_id))
	
	--local worked = pcall(function() dorhud_log("blname: \"" .. unit:base()._blname .. "\"") end)
	
	--if not worked then dorhud_log("pcall didn't work") end

	local success, proto_mask_name = pcall(function()
		return managers.criminals:character_data_by_name(character_name_id).mask_icon
	end)

	local mask_name = success and proto_mask_name or "clowns"
	local mask_icon, mask_texture_rect = tweak_data.hud_icons:get_icon_data(mask_name)
	local use_lifebar = is_husk_player and true or false
	local mugshot_id = managers.hud:add_mugshot({
		name = string.upper(character_name),
		use_lifebar = use_lifebar,
		mask_icon = mask_icon,
		mask_texture_rect = mask_texture_rect,
		crew_bonus = crew_bonus,
		peer_id = peer_id,
		character_name_id = character_name_id,
		location_text = location_text
	})
	unit:unit_data().mugshot_id = mugshot_id
	return mugshot_id
end

function HUDManager:_layout_mugshots()
	local hud = managers.hud:script(PlayerBase.PLAYER_HUD)
	local info_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local _, hy = hud.panel:center()
	for i, mugshot in ipairs(self._hud.mugshots) do
		local _, sy = mugshot.panel:size()
		local y = i == 1 and info_hud.health_panel:bottom() or self._hud.mugshots[i-1].panel:top() - 2 * tweak_data.scale.hud_health_multiplier
		local icon_size = 34/2
		local pad = 4
		local w, h = 176 * tweak_data.scale.hud_mugshot_multiplier, (icon_size + pad * 2) * tweak_data.scale.hud_mugshot_multiplier
		mugshot.panel:set_size(w, h)
		mugshot.panel:set_left(info_hud.health_panel:right() + 2)
		mugshot.panel:set_bottom(y)
		mugshot.gradient:set_size(w, h)
		local _, background_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_background")
		mugshot.health_background:set_size(background_rect[3] * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.health_background:set_left(4 * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.mask:set_size(icon_size * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.mask:set_left(mugshot.health_background:right() + 4 * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.mask:set_center_y(mugshot.gradient:h() / 2)
		mugshot.state_icon:set_shape(mugshot.mask:shape())
		mugshot.talk:set_righttop(mugshot.mask:righttop())
		mugshot.voice:set_righttop(mugshot.mask:righttop())
		mugshot.health_background:set_top(mugshot.mask:top())
		mugshot.health_armor:set_size(background_rect[3] * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.health_armor:set_center_x(mugshot.health_background:center_x())
		mugshot.health_armor:set_bottom(mugshot.health_background:bottom())
		mugshot.health_health:set_size(background_rect[3] * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.health_health:set_center_x(mugshot.health_background:center_x())
		mugshot.health_health:set_bottom(mugshot.health_background:bottom())
		self:layout_mugshot_health(mugshot, mugshot.health_amount or 1)
		self:layout_mugshot_armor(mugshot, mugshot.armor_amount or 1)
		if mugshot.crew_bonus then
			mugshot.crew_bonus:set_left(mugshot.mask:right() + 4)
			mugshot.crew_bonus:set_bottom(mugshot.mask:bottom())
		end

		self:_layout_mugshot_equipment(mugshot)
		local font_size = 14 * tweak_data.scale.hud_mugshot_multiplier
		mugshot.name:set_font_size(font_size)
		mugshot.name:set_kern(tweak_data.scale.mugshot_name_kern)
		local _, _, w, _ = mugshot.name:text_rect()
		mugshot.name:set_w(w)
		mugshot.name:set_left(mugshot.mask:right() + 4 * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.name:set_top(mugshot.mask:top() * tweak_data.scale.hud_mugshot_multiplier)
		mugshot.state_text:set_kern(tweak_data.scale.mugshot_name_kern)
		mugshot.state_text:set_font_size(font_size)
		mugshot.state_text:set_left(mugshot.name:right() + 4)
		mugshot.state_text:set_top(mugshot.name:top())
		mugshot.location_text:set_kern(tweak_data.scale.mugshot_name_kern)
		mugshot.location_text:set_font_size(font_size)

		mugshot.location_text:set_left(mugshot.state_text:right() + 4)
		mugshot.location_text:set_top(mugshot.name:top())
		mugshot.panel:set_w(mugshot.name:w() + 4 + mugshot.state_text:w())
		mugshot.timer_text:set_font_size(tweak_data.hud.small_font_size)
		mugshot.timer_text:set_center(mugshot.health_background:center())
		self:_update_mugshot_panel_size(mugshot)
	end

end