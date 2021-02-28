dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("mods/DialogSystem/files/dialog_system.lua")

wake_up_waiting_threads(1)

function interacting(entity_who_interacted, entity_interacted, interactable_name)
  dialog_system.open_dialog({
    {
      image = "mods/DialogSystem/files/portrait.png",
      align_image = dialog_system.LEFT,
      message = "Test *Blink* Test ~Test~ Test!",
      -- message = "Hey, you!{@pause 40} Yes, {@pause 40}{@delay 2}YOU!\n{@pause 50}{@delay 2}Would you like to buy some{@delay 20}... {@delay 5}*DRUGS*?\n{@pause 50}{@delay 3}I got a *whole marihuna* for sale, dude!",
      options = {
        {
          text = "Yes",
          func = function(dialog)
            GamePrint("Yes clicked")
            dialog.show({
              image = "mods/DialogSystem/files/portrait.png",
              align_image = dialog_system.LEFT,
              message = "Good choice, buddy!",
            })
          end
        },
        {
          text = "No, I'm too cool to do drugs!",
          func = function(dialog)
            dialog.show({
              image = "mods/DialogSystem/files/portrait.png",
              align_image = dialog_system.LEFT,
              message = "Fine, whatever man.",
            })
          end
        },
      }
    },
    {
      image = "mods/DialogSystem/files/portrait2.png",
      message = "Hello, how are you?"
    }
  })
end
