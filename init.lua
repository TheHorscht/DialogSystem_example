dofile_once("mods/DialogSystem/lib/DialogSystem/init.lua")("mods/DialogSystem/lib/DialogSystem")

function OnPlayerSpawned(player_entity)
  local x, y = EntityGetTransform(player_entity)
  EntityLoad("mods/DialogSystem/files/npc.xml", x, y - 50)
end
