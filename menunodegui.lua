local module = ... or D:module("BiggerLobbies")
local MenuNodeGui = module:hook_class("MenuNodeGui")

MenuNodeGui._setup_main_panel = function(self, safe_rect, shape)
	local res = RenderSettings.resolution
	shape = shape or {}
	local x = shape.x or safe_rect.x
	local y = shape.y or safe_rect.y + self._topic_panel:height()
	local w = shape.w or safe_rect.width
	local h = shape.h or safe_rect.height - self._topic_panel:height() * 2
	self._main_panel:set_shape(x, y, w, h)
	self._align_data.panel:set_h(self._main_panel:h())
	self._list_arrows.up:set_h(20 * tweak_data.scale.menu_arrow_padding_multiplier)
	self._list_arrows.up:set_lefttop(self._align_data.panel:world_center(), self._align_data.panel:world_top() + 1.5)
	self._list_arrows.down:set_h(20 * tweak_data.scale.menu_arrow_padding_multiplier)
	self._list_arrows.down:set_leftbottom(self._align_data.panel:world_center(), self._align_data.panel:world_bottom() - 1.5)
	self._legends_panel:set_top(self._main_panel:bottom() + tweak_data.load_level.border_pad)
	self._main_panel:set_y(self._main_panel:y() + 24 * tweak_data.scale.menu_arrow_padding_multiplier)
	self._main_panel:set_h(self._main_panel:h() - 48 * tweak_data.scale.menu_arrow_padding_multiplier)
end