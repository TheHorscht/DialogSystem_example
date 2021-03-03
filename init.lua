-- dofile_once("mods/DialogSystem/files/dialog_system.lua")
local nxml = dofile_once("mods/DialogSystem/lib/nxml.lua")

local filename = "mods/DialogSystem/files/transition.xml"
local content = ModTextFileGetContent(filename)
local xml = nxml.parse(content)
for i = 0, 32 do
  xml:add_child(nxml.parse(string.format([[
    <RectAnimation
      frame_count="1"
      frames_per_row="1"
      frame_height="64"
      frame_width="64"
      frame_wait="0.2"
      name="anim_%d"
      pos_x="0"
      pos_y="%d"
      >
    </RectAnimation>
  ]], 32 - i, 64 * 2 - i * 4)))
end
print(tostring(xml))
ModTextFileSetContent(filename, tostring(xml))

function OnPlayerSpawned(player_entity)
  if not GameHasFlagRun("dashmod_script_applied") then
    GameAddFlagRun("dashmod_script_applied")
  -- if GlobalsGetValue("dashmod_script_applied", "0") == "0" then
    EntityAddComponent2(player_entity, "LuaComponent", {
      script_source_file="mods/DialogSystem/files/dash.lua",
      execute_every_n_frame=1,
    })
  end

  local x, y = EntityGetTransform(player_entity)
  EntityLoad("mods/DialogSystem/files/npc.xml", x, y)
  -- dialog_system.open_dialog({
  --   {
  --     image = "mods/DialogSystem/files/portrait.png",
  --     align_image = dialog_system.LEFT,
  --     message = "Hello, how are you?"
  --   },
  --   {
  --     image = "mods/DialogSystem/files/portrait2.png",
  --     message = "Hello, how are you?"
  --   }
  -- })
end

-- function OnWorldPreUpdate()
--   dialog_system.update()
-- end
