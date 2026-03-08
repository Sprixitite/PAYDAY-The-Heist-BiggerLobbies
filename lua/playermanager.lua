Hooks:PreHook(PlayerManager, "spawn_players", "spawn_players_bl", function(self, pos, rot, state)
	self._nr_players = bl.bl_total_playable_crims
end)
