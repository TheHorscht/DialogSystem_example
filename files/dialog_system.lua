dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")
local Color = dofile_once("mods/DialogSystem/lib/color.lua")

dialog_system = {
  LEFT = 1,
  RIGHT = 2,
}

gui = GuiCreate()
dialog = nil

local function render_dialog_box()
  
end

dialog_system.open_dialog = function (messages)
  -- EntityLoad("mods/DialogSystem/files/dialog_ui.xml", x, y)
  -- print("Etntiy loadddddddddddeeeeeeeeeeeeed")
  dialog = {
    transition_state = 0,
    messages = messages
  }
  async(function()
    for i=1, 32 do
      GuiStartFrame(gui)
      local screen_width, screen_height = GuiGetScreenDimensions(gui)
      local width = dialog.transition_state * 300
      local height = dialog.transition_state * 70
      GuiIdPushString(gui, "boop")
      dialog.transition_state = dialog.transition_state + (1 / 30)
      GuiZSetForNextWidget(gui, -2)
      GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
      GuiIdPop(gui)
      wait(0)
    end
    for i=0, 32*3 do
      GuiStartFrame(gui)
      local screen_width, screen_height = GuiGetScreenDimensions(gui)
      local width = dialog.transition_state * 300
      local height = dialog.transition_state * 70
      local x, y = screen_width/2 - width/2, screen_height - 100 - height/2
      y = y + (height/2) - (64/2)
      x = x + 6
      GuiIdPushString(gui, "boop")
      GuiZSetForNextWidget(gui, 2)
      GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
      GuiZSetForNextWidget(gui, 1)
      GuiImage(gui, 2, x, y, "mods/DialogSystem/files/portrait.png", 1, 1, 1, 0)
      GuiZSetForNextWidget(gui, 0)
      GuiImage(gui, 3, x, y, "mods/DialogSystem/files/transition.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause, "anim_" .. tostring(math.floor(32*3-i)/3))
      GuiZSetForNextWidget(gui, -1)
      GuiImage(gui, 4, x, y, "mods/DialogSystem/files/border.png", 1, 1, 1, 0)
      GuiIdPop(gui)
      wait(0)
    end
    -- local text = "Hello, I am Garbinald the Wizerd, listen to my magic words:\n...\n\"UOY KCUF!\""
    -- local text = "Yo shiiiit what's this?! A dialog box in Noita? No way!\nIt even has multiple lines.\nAnd... *WAVY RAINBOW TEXT?!* Wow! Cool!"
    -- local text = "Check out this stupid little idea that I had.\nDialog boxes in Noita!.\nWith... *WAVY RAINBOW TEXT?!* Sure, why not!"
    -- local text = "Hey, you!{@pause 30} Yes, YOU!\nWould you like to buy... some *drugs*?"
    local text = "Hey, you! Yes, YOU!\nWould you like to buy some... *DRUGS*?"
    local counter = 0
    local i = 1
    while i <= #text + 60 do
      GuiStartFrame(gui)
      local screen_width, screen_height = GuiGetScreenDimensions(gui)
      local width = dialog.transition_state * 300
      local height = dialog.transition_state * 70
      local x, y = screen_width/2 - width/2, screen_height - 100 - height/2
      y = y + (height/2) - (64/2)
      x = x + 6
      GuiIdPushString(gui, "boop")
      GuiZSetForNextWidget(gui, 2)
      GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
      GuiZSetForNextWidget(gui, 1)
      GuiImage(gui, 2, x, y, "mods/DialogSystem/files/portrait.png", 1, 1, 1, 0)
      GuiZSetForNextWidget(gui, -1)
      GuiImage(gui, 4, x, y, "mods/DialogSystem/files/border.png", 1, 1, 1, 0)
      local substr = text:sub(1, math.min(#text,i))
      GuiLayoutBeginHorizontal(gui, x + 72, y, true)
      local y_offset = 0
      local wave = false
      for j=1, #substr do
        local char = substr:sub(j, j)
        if char == "\n" then
          y_offset = y_offset + 12
          GuiLayoutEnd(gui)
          GuiLayoutBeginHorizontal(gui, x + 72, y, true)
        elseif char == "*" then
          wave = not wave
        else
          local wave_offset_y = 0
          if wave then
            local color = Color:new(math.cos(j * 0.04 + GameGetFrameNum() * 0.03) * 360, 0.5, 0.5)
            local r, g, b = color:get_rgb()
            GuiColorSetForNextWidget(gui, r, g, b, 1)
            wave_offset_y = math.sin(j * 0.5 + GameGetFrameNum() * 0.1) * 1
          end
          GuiText(gui, -2, y_offset + wave_offset_y, char)
        end
      end
      GuiLayoutEnd(gui)
      GuiIdPop(gui)
      if counter > 3 then
        i = i + 1
        counter = 0
      end
      counter = counter + 1
      wait(0)
    end
  end)
end

-- dialog_system.update = function ()
--   if not dialog then return end
--   local screen_width, screen_height = GuiGetScreenDimensions(gui)
--   local width = dialog.transition_state * 300
--   local height = dialog.transition_state * 100
--   dialog.transition_state = math.min(1, dialog.transition_state + (1 / 30))
--   GuiStartFrame(gui)
--   -- GuiImageNinePiece( gui:obj, id:int, x:number, y:number, width:number, height:number, alpha:number = 1, sprite_filename:string = "data/ui_gfx/decorations/9piece0_gray.png", sprite_highlight_filename:string = "data/ui_gfx/decorations/9piece0_gray.png" )
--   GuiIdPushString(gui, "boop")
--   -- GuiAnimateBegin(gui)
--   GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
--   -- GuiAnimateEnd(gui)
--   GuiIdPop(gui)
--   -- GuiAnimateScaleIn(gui, 2, 1, false)
-- end
