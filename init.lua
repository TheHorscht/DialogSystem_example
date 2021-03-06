dofile_once("mods/DialogSystem/lib/DialogSystem/init.lua")("DialogSystem/lib/DialogSystem", {
  ruby = "mods/DialogSystem/files/ruby.png" -- This is how you add custom icons to be used
})

function OnPlayerSpawned(player_entity)
  local x, y = EntityGetTransform(player_entity)
  EntityLoad("mods/DialogSystem/files/npc.xml", x, y - 50)
end
