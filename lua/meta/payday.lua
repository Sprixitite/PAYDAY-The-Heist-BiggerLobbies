---@meta
---@module "meta.diesel"

---@class PD_MissionElement_End : Diesel_Class
---@field _values table
_G.ElementMissionEnd = _G.ElementMissionEnd

---@class PD_CriminalsManager : Diesel_Class
---@field add_character function
---@field set_unit function
---@field getchar fun(self: PD_CriminalsManager, char_name: string) : string
---@field chartaken fun(self: PD_CriminalsManager, char_id: string) : number
---@field get_free_character_name fun(self: PD_CriminalsManager, refuse_contingent: boolean?) : string
---@field character_name_by_unit fun(self: PD_CriminalsManager, unit: Diesel_Unit) : string
---@field character_data_by_name fun(self: PD_CriminalsManager, name: string) : table
---@field character_name_by_peer_id fun(self: PD_CriminalsManager, peer_id: any): string
---@field _characters table
_G.CriminalsManager = _G.CriminalsManager

---@class PD_LocalizationManager : Diesel_Class
---@field text fun(self: PD_LocalizationManager, id: string) : string
_G.LocalizationManager = _G.LocalizationManager

---@class PD_MenuLobbyRenderer : Diesel_Class
_G.MenuLobbyRenderer = _G.MenuLobbyRenderer

---@class PD_UserManager : Diesel_Class
---@field get_setting fun(self: PD_UserManager, setting_name: string) : any
_G.UserManager = _G.UserManager

---@class PD_MenuManager : Diesel_Class
---@field created_lobby fun(self: PD_MenuManager)
---@field show_retrieving_servers_dialog fun(self: PD_MenuManager)
---@field get_menu fun(self: PD_MenuManager, menu_id: string) : table
---@field active_menu fun(self: PD_MenuManager) : any
_G.MenuManager = _G.MenuManager

---@class PD_SystemMenuManager : Diesel_Class
---@field close fun(self: PD_SystemMenuManager, id: string)
---@field show fun(self: PD_SystemMenuManager, data: table)
_G.SystemMenuManager = _G.SystemMenuManager

---@class PD_NetworkGame : Diesel_Class
_G.NetworkGame = _G.NetworkGame

---@class PD_MenuRenderer : Diesel_Class
---@field setup_frames_and_logo function
_G.MenuRenderer = _G.MenuRenderer

---@class PD_VideoManager : Diesel_Class
---@field add_video fun(self: PD_VideoManager, video: Diesel_Video)
_G.VideoManager = _G.VideoManager

---@class PD_PlayerManager : Diesel_Class
---@field player_unit fun(self: PD_PlayerManager) : Diesel_Unit
---@field get_crew_bonus_by_peer fun(self: PD_PlayerManager, peer_id: number) : any
---@field spawned_player fun(self: PD_PlayerManager, idx: number, unit: Diesel_Unit)
---@field WEAPON_SLOTS number
---@field _player_mesh_suffix string
_G.PlayerManager = _G.PlayerManager

---@class PD_PlayerMovement : Diesel_Class
_G.PlayerMovement = _G.PlayerMovement

---@class PD_HuskPlayerMovement : Diesel_Class
---@field _char_model_names table
---@field _char_name_to_index table
_G.HuskPlayerMovement = _G.HuskPlayerMovement

---@class PD_NetworkManager : Diesel_Class
---@field spawn_point fun(self: PD_NetworkManager, id: any) : any
---@field session fun(self) : any
---@field game fun(self) : any
---@field DROPIN_ENABLED boolean
---@field matchmake PD_Matchmaker
_G.NetworkManager = _G.NetworkManager

---@class PD_MenuNodeGui : Diesel_Class
_G.MenuNodeGui = {}

---@class PD_HostNetworkSession : Diesel_Class
_G.HostNetworkSession = _G.HostNetworkSession

---@class PD_BaseNetworkHandler : Diesel_Class
---@field _gamestate_filter table<string, boolean|table>
_G.BaseNetworkHandler = _G.BaseNetworkHandler

---@class PD_NetworkMember : Diesel_Class
_G.NetworkMember = _G.NetworkMember

---@class PD_Matchmaker : Diesel_Class
---@field set_server_joinable fun(self: PD_Matchmaker, to: boolean)
---@field set_num_players     fun(self: PD_Matchmaker, to: number)

---@class PD_NetworkMatchMakingSTEAM : Diesel_Class

_G.NetworkMatchMakingSTEAM = _G.NetworkMatchMakingSTEAM

---@class PD_PlatformManager : Diesel_Class
---@field presence fun(self: PD_PlatformManager) : PD_PlatformManager_Presence
---@field set_presence fun(self: PD_PlatformManager, to: PD_PlatformManager_Presence)
_G.PD_PlatformManager = _G.PD_PlatformManager

---@alias PD_PlatformManager_Presence
---| "Idle"
---| "Mission_end"
---| "Signed_in"
---| "Playing"
---| "MPLobby"
---| "MPLobby_no_invite"

---@class PD_HudManager : Diesel_Class
---@field script               fun(self: PD_HudManager, name: Diesel_Idstring) : any
---@field _add_name_label      fun(self: PD_HudManager, tbl: table)
---@field set_mugshot_normal   fun(self: PD_HudManager, mug_id: any)
---@field set_mugshot_armor    fun(self: PD_HudManager, mug_id: any, amt: number)
---@field set_mugshot_health   fun(self: PD_HudManager, mug_id: any, amt: number)
---@field set_mugshot_location fun(self: PD_HudManager, mug_id: any, id:  any)
_G.HUDManager = _G.HUDManager

---@class PD_PlayerBase : Diesel_Class
---@field PLAYER_HUD Diesel_Idstring
---@field PLAYER_INFO_HUD Diesel_Idstring
_G.PlayerBase = _G.PlayerBase

---@class PD_GroupAIManager : Diesel_Class
---@field state fun(self: PD_GroupAIManager) : PD_GroupAIManagerState
_G.GroupAIManager = _G.GroupAIManager

---@class PD_GroupAIManagerState
---@field remove_one_teamAI function
---@field all_char_criminals function
---@field is_teamAI_marked_for_removal fun(self: PD_GroupAIManagerState, char_id: string) : boolean
---@field amount_of_winning_ai_criminals fun(self: PD_GroupAIManagerState) : number
---@field chk_allow_drop_in fun(self: PD_GroupAIManagerState) : boolean
---@field is_AI_enabled fun(self: PD_GroupAIManagerState) : boolean

---@class PD_GroupAIStateBase
_G.GroupAIStateBase = _G.GroupAIStateBase

---@class PD_NavigationManager : Diesel_Class
---@field raycast fun(self: PD_NavigationManager, params: table) : boolean
_G.NavigationManager = _G.NavigationManager

---@class PD_NetworkGlobal
---@field spawn_unit_on_client function
---@field is_client fun(self: PD_NetworkGlobal) : boolean
---@field is_server fun(self: PD_NetworkGlobal) : boolean
---@field add_client fun(self: PD_NetworkGlobal, id: any)
_G.Network = {}

---@class PD_HostStateInLobby : Diesel_Class
_G.HostStateInLobby = _G.HostStateInLobby

---@class PD_Managers : Diesel_Managers
---@field network          PD_NetworkManager
---@field hud              PD_HudManager
---@field criminals        PD_CriminalsManager
---@field player           PD_PlayerManager
---@field groupai          PD_GroupAIManager
---@field platform         PD_PlatformManager
---@field navigation       PD_NavigationManager
---@field localization     PD_LocalizationManager
---@field video            PD_VideoManager
---@field user             PD_UserManager
---@field menu             PD_MenuManager
---@field system_menu      PD_SystemMenuManager
---@field editor           table
---@type PD_Managers
---@diagnostic disable-next-line
_G.managers = {}

---@type table
_G.tweak_data = {}