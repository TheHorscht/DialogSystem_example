dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("mods/DialogSystem/files/dialog_system.lua")

wake_up_waiting_threads(1)

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
local player = EntityGetInRadiusWithTag(x, y, 20, "player_unit")[1]
local character_platforming_component = EntityGetFirstComponentIncludingDisabled(entity_id, "CharacterPlatformingComponent")
if player then
  ComponentSetValue2(character_platforming_component, "run_velocity", 0)
else
  ComponentSetValue2(character_platforming_component, "run_velocity", 30)
end

local sounds = { "sans", "one", "two", "three", "four" }

function interacting(entity_who_interacted, entity_interacted, interactable_name)
  local sound_index = tonumber(GlobalsGetValue("sound_index", "1"))
  GlobalsSetValue("sound_index", sound_index % #sounds + 1)
  GamePrint("Current sound: " .. tostring(sounds[sound_index]))
  GlobalsSetValue("sound", sounds[sound_index])
  dialog_system.open_dialog({
    {
      image = "mods/DialogSystem/files/portrait.png",
      align_image = dialog_system.LEFT,
      -- message = "Test *Blink* Test ~Test~ Test!",
      -- message = "{@color FF0000}Red {@color 00FF00}green {@color 0000FF}blue {@color 6c834d}whatever!{@color FFFFFF}\n~Wavy~ #Shakey# *blinking*.\nPause,{@pause 60} {@delay 10}slow text, {@delay 1}fast text fast text fast text.\n{@delay 0}Instant text instant text instant text!{@pause 30}{@delay 3}\n~*#Combined woooah!#*~",
      -- text = [[
      --   {@color FF0000}Red {@color 00FF00}green {@color 0000FF}blue {@color 6c834d}whatever!{@color FFFFFF}
      --   ~Wavy~ #Shakey# *blinking*.
      --   Pause,{@pause 60} {@delay 10}slow text, {@delay 1}fast text fast text fast text.
      --   {@delay 0}Instant text instant text instant text!{@pause 30}{@delay 3}
      --   ~*#Combined woooah!#*~
      -- ]],
      text = [[
        {@delay 2}Lamp oil? Rope? #Bombs#? You want it?
        {@delay 3}Lamp oil? Rope? #Bombs#? You want it?
        {@delay 5}Lamp oil? Rope? #Bombs#? You want it?
        {@delay 7}Lamp oil? Rope? #Bombs#? You want it?
      ]]
      -- text = "Lamp oil? Rope? #Bombs#? You want it?\nIt's yours my friend, as long as you have enough rubies."
      -- message = "Hey, you!{@pause 40} Yes, {@pause 40}{@delay 2}YOU!\n{@pause 50}{@delay 2}Would you like to buy some{@delay 20}... {@delay 5}~DRUGS~?\n{@pause 50}{@delay 3}I got a *whole marihuna* for sale, dude!",
    --   options = {
    --     {
    --       text = "That's pretty cool, can I go home now?",
    --       func = function(dialog)
    --         dialog.show({
    --           image = "mods/DialogSystem/files/portrait.png",
    --           align_image = dialog_system.LEFT,
    --           message = "Good choice, buddy!",
    --         })
    --       end
    --     },
    --     {
    --       text = "No, I'm too cool to do drugs!",
    --       func = function(dialog)
    --         -- dialog.close()
    --         dialog.show({
    --           image = "mods/DialogSystem/files/portrait.png",
    --           align_image = dialog_system.LEFT,
    --           message = "#WHAT?# {@delay 20}...{@delay 3}Whatever man.",
    --         })
    --       end
    --     },
    --   }
    },
    {
      image = "mods/DialogSystem/files/portrait2.png",
      text = "Hello, how are you?",
    }
  })
end
