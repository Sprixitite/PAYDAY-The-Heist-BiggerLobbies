local module = ... or D:module("BiggerLobbies")
local PlayerManager = module:hook_class("PlayerManager")

module:pre_hook(PlayerManager, "spawn_players", function(self, pos, rot, state)
	self._nr_players = bl.bl_total_playable_crims
end, false)
