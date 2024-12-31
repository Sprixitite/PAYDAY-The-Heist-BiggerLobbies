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
    
    local mugshotWidth = 176 * tweak_data.scale.hud_mugshot_multiplier
    local toLayout = #self._hud.mugshots
    local padding, mugshotGroupSize
    if bl.bl_total_playable_crims < 9 then
        padding = 4
        mugshotGroupSize = 4
    else
        -- Less pretty, more space efficient
        padding = 2
        mugshotGroupSize = 6
    end
    local mugshotHeight = math.abs(info_hud.health_panel:bottom() - info_hud.health_panel:top() + (padding/2)) / mugshotGroupSize
    mugshotHeight = (mugshotHeight - (padding / 2)) * tweak_data.scale.hud_mugshot_multiplier
    for i, mugshot in ipairs(self._hud.mugshots) do
        local mugshotGroup = math.ceil(i/mugshotGroupSize)
        local needsGradient = toLayout <= mugshotGroupSize
        local inGroup = ((i-1) % mugshotGroupSize)+1 -- Fuck 1 based indexing

        local y = inGroup == 1 and info_hud.health_panel:bottom() or self._hud.mugshots[inGroup-1].panel:top() - (padding/2) * tweak_data.scale.hud_health_multiplier
        local icon_size = mugshotHeight - padding
        
        local w, h = mugshotWidth, mugshotHeight
        mugshot.panel:set_size(w, h)
        mugshot.panel:set_left(info_hud.health_panel:right() + (padding/2) + (mugshotGroup-1)*mugshotWidth)
        mugshot.panel:set_bottom(y)
        if not needsGradient then
            -- No gradient unless in final group
            mugshot.gradient:set_gradient_points({
                0,
                Color(0.4, 0, 0, 0),
                1,
                Color(0.4, 0, 0, 0)
            })
        end
        mugshot.gradient:set_size(w, h)
        local _, background_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_background")
        mugshot.health_background:set_size(background_rect[3] * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
        mugshot.health_background:set_left(padding * tweak_data.scale.hud_mugshot_multiplier)
        mugshot.mask:set_size(icon_size * tweak_data.scale.hud_mugshot_multiplier, icon_size * tweak_data.scale.hud_mugshot_multiplier)
        mugshot.mask:set_left((padding/2) * tweak_data.scale.hud_mugshot_multiplier)
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
            mugshot.crew_bonus:set_left(mugshot.mask:right() + padding)
            mugshot.crew_bonus:set_bottom(mugshot.mask:bottom())
        end

        self:_layout_mugshot_equipment(mugshot)
        local font_size = 14 * tweak_data.scale.hud_mugshot_multiplier
        mugshot.name:set_font_size(font_size)
        mugshot.name:set_kern(tweak_data.scale.mugshot_name_kern)
        local _, _, w, _ = mugshot.name:text_rect()
        mugshot.name:set_w(w)
        mugshot.name:set_h(mugshot.gradient:h())
        mugshot.name:set_left(mugshot.mask:right() + padding * tweak_data.scale.hud_mugshot_multiplier)
        mugshot.name:set_top((mugshot.gradient:h()/2) * tweak_data.scale.hud_mugshot_multiplier)
        mugshot.state_text:set_kern(tweak_data.scale.mugshot_name_kern)
        mugshot.state_text:set_font_size(font_size)
        mugshot.state_text:set_left(mugshot.name:right() + padding)
        mugshot.state_text:set_top(mugshot.name:top())

        -- Cannot for the life of me get this stupid fucking text to center vertically
        mugshot.location_text:set_kern(tweak_data.scale.mugshot_name_kern)
        mugshot.location_text:set_font_size(font_size)

        mugshot.location_text:set_left(mugshot.state_text:right() + padding)
        mugshot.location_text:set_size(mugshot.gradient:size())
        mugshot.location_text:set_center_y(mugshot.gradient:center_y())

        mugshot.panel:set_w(mugshot.name:w() + padding + mugshot.state_text:w())
        mugshot.timer_text:set_font_size(tweak_data.hud.small_font_size)
        mugshot.timer_text:set_center(mugshot.health_background:center())
        self:_update_mugshot_panel_size(mugshot)

        toLayout = toLayout - 1
    end

end