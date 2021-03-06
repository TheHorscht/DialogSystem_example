dofile_once("mods/DialogSystem/lib/DialogSystem/dialog_system.lua")
local config = dofile_once("data/virtual/DialogSystem_config.lua")

-- Make NPC stop walking while player is close
local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
local player = EntityGetInRadiusWithTag(x, y, config.distance_to_close, "player_unit")[1]
local character_platforming_component = EntityGetFirstComponentIncludingDisabled(entity_id, "CharacterPlatformingComponent")
if player then
  ComponentSetValue2(character_platforming_component, "run_velocity", 0)
else
  ComponentSetValue2(character_platforming_component, "run_velocity", 30)
end

function interacting(entity_who_interacted, entity_interacted, interactable_name)
  dialog = dialog_system.open_dialog({
    portrait = "mods/DialogSystem/files/morshu.xml",
    animation = "morshu", -- Which animation to use
    typing_sound = "sans", -- There are currently 5: sans, one, two, three, four and "none" to turn it off, if not specified defaults to two
    text = [[
      Normal text, pause for 60 frames: {@pause 60}{@delay 10}Slow text{@delay 3}{@color FF0000} text color{@color FFFFFF}
      *Blinking text*, #shaking text#, ~rainbow wave text~, ~*#combined#*~
      You can even use custom icons/images! {@img ruby}{@img ruby}{@img ruby}
      Which also support all modifiers: #{@img ruby}#*{@img ruby}*~{@img ruby}~~*#{@img ruby}#*~
    ]],
    options = {
      {
        text = "Option one",
        func = function(dialog)
          dialog.show({
            portrait = "mods/DialogSystem/files/portrait.png",
            text = "Now I am a wizerd!\nBlablabla some more text... but with default typing sound."
          })
          -- dialog.close() to close it
        end
      },
      {
        text = "An option without a 'func' property closes the dialog",
      },
    }
  })
end
