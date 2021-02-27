dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("mods/DialogSystem/files/dialog_system.lua")

wake_up_waiting_threads(1)

function interacting(entity_who_interacted, entity_interacted, interactable_name)
  -- async(function ()
  -- end)
  dialog_system.open_dialog({
    {
      image = "mods/DialogSystem/files/portrait.png",
      align_image = dialog_system.LEFT,
      message = "Hey, you! Yes, YOU!\nWould you like to buy some... *DRUGS*?"
    },
    {
      image = "mods/DialogSystem/files/portrait2.png",
      message = "Hello, how are you?"
    }
  })
end
