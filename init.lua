dofile_once("mods/DialogSystem_example/lib/DialogSystem/init.lua")("mods/DialogSystem_example/lib/DialogSystem")

function OnPlayerSpawned(player_entity)
  local x, y = EntityGetTransform(player_entity)
  EntityLoad("mods/DialogSystem_example/files/morshu/npc.xml", x, y - 50)
end
