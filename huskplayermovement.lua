local module = ... or D:module("BiggerLobbies")
local HuskPlayerMovement = module:hook_class("HuskPlayerMovement")

function define_the_things(self)
	self._char_name_to_index = {}
	self._char_model_names = {}
    local heisters = bl:bl_heisters()
	for i=0, bl:bl_additional_crims()+3 do

		local index = (i%4)+1
		
		local basename = heisters[index]
		local suffix = "_" .. tostring(math.floor(i/4)+1)
		
		local addname = suffix == "_1" and basename or basename .. suffix
		
		self._char_name_to_index[addname] = index
		
		local modelname = ( basename == "german" and "g_body" ) or ( basename == "spanish" and "g_spaniard" ) or ( "g_" .. basename )
		
		self._char_model_names[addname] = modelname
		
	end
	HuskPlayerMovement._char_model_names = self._char_model_names
	HuskPlayerMovement._char_name_to_index = self._char_name_to_index
end

HuskPlayerMovement.set_character_anim_variables = function(self)
	local char_name = _G.bl:get_blname(self._unit) or managers.criminals:character_name_by_unit(self._unit)
	if not char_name then
		return
	end
	
	define_the_things(self)

	local mesh_name = self._char_model_names[char_name] .. (managers.player._player_mesh_suffix or "")
	local mesh_obj = self._unit:get_object(Idstring(mesh_name))
	if mesh_obj then
		self._unit:get_object(Idstring(self._plr_mesh_name or self._char_model_names.german)):set_visibility(false)
		local char_index = self._char_name_to_index[char_name]
		self._machine:set_global("husk" .. tostring(char_index), 1)
		mesh_obj:set_visibility(true)
		self._plr_mesh_name = mesh_name
	end

end
