local dialog_system = dofile_once("mods/DialogSystem_example/lib/DialogSystem/dialog_system.lua")

-- Make NPC stop walking while player is close
local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
local player = EntityGetInRadiusWithTag(x, y, 15, "player_unit")[1]
local character_platforming_component = EntityGetFirstComponentIncludingDisabled(entity_id, "CharacterPlatformingComponent")
if player then
  ComponentSetValue2(character_platforming_component, "run_velocity", 0)
else
  ComponentSetValue2(character_platforming_component, "run_velocity", 30)
end

function interacting(entity_who_interacted, entity_interacted, interactable_name)
  dialog_system.images.ruby = "mods/DialogSystem_example/files/ruby.png" -- This is how you add custom icons to be used by the img command
  -- dialog_system.dialog_box_y = 10 -- Optional
  -- dialog_system.dialog_box_width = 300 -- Optional
  -- dialog_system.dialog_box_height = 70 -- Optional
  -- dialog_system.distance_to_close = 15 -- Optional
  dialog = dialog_system.open_dialog({
    name = "Morshu",
    portrait = "mods/DialogSystem_example/files/morshu/portrait.xml",
    animation = "morshu", -- Which animation to use
    typing_sound = "one", -- There are currently 5: sans, one, two, three, four and "none" to turn it off, if not specified defaults to two
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
            name = "Noita",
            portrait = "mods/DialogSystem_example/files/wizard_portrait.png",
            typing_sound = "three",
            text = "Shut the fuck up Morshu, nobody cares!"
          })
          -- To close the dialog you can also use dialog.close()
        end
      },
      {
        text = "An option without a 'func' property closes the dialog",
      },
    }
  })
end
