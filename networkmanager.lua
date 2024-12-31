local module = ... or D:module("BiggerLobbies")
local NetworkManager = module:hook_class("NetworkManager")

-- Modified to alter the display of player count in lobbies

module:post_hook(NetworkManager, "on_peer_added", function(self, peer, peer_id)
    if Network:is_server() then
        -- Change the crime.net display to show the % of players relative to the lobby size set by host.
        local ratio = managers.network:session():amount_of_players() / bl.bl_total_playable_crims
        local ratio_to_icon = math.clamp( math.ceil(4 * ratio), 1, 4 )

        managers.network.matchmake:set_num_players( ratio_to_icon )
    end
end)