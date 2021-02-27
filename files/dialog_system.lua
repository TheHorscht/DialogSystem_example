dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")
local Color = dofile_once("mods/DialogSystem/lib/color.lua")

local dialog_box_width = 300
local dialog_box_height = 70

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
  local lines = { {} }
  local current_line = lines[1]
  -- Render the GUI
  async_loop(function()
    GuiStartFrame(gui)
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local width = dialog.transition_state * dialog_box_width
    local height = dialog.transition_state * dialog_box_height
    local x, y = screen_width/2 - width/2, screen_height - 100 - height/2
    y = y + (height/2) - (64/2)
    x = x + 6
    GuiIdPushString(gui, "dialog_box")
    GuiZSetForNextWidget(gui, 2)
    GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
    if dialog.fade_in_portrait then
      -- local i = dialog.fade_in_portrait --tostring(math.floor(32*3-i)/3)
      GuiZSetForNextWidget(gui, 1)
      GuiImage(gui, 2, x, y, "mods/DialogSystem/files/portrait.png", 1, 1, 1, 0)
      GuiZSetForNextWidget(gui, 0)
      GuiImage(gui, 3, x, y, "mods/DialogSystem/files/transition.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause, "anim_" .. tostring(dialog.fade_in_portrait))
      GuiZSetForNextWidget(gui, -1)
      GuiImage(gui, 4, x, y, "mods/DialogSystem/files/border.png", 1, 1, 1, 0)
    end
    -- Render text
    local y_offset = 0
    local char_i = 1
    for i, line in ipairs(lines) do
      GuiLayoutBeginHorizontal(gui, x + 72, y, true)
      for i2, char_data in ipairs(line) do
        local wave_offset_y = 0
        if char_data.wave then
          local color = Color:new(math.cos(char_i * 0.14 + GameGetFrameNum() * 0.03) * 360, 0.5, 0.5)
          local r, g, b = color:get_rgb()
          GuiColorSetForNextWidget(gui, r, g, b, 1)
          wave_offset_y = math.sin(char_i * 0.5 + GameGetFrameNum() * 0.1) * 1
        end
        GuiText(gui, -2, y_offset + wave_offset_y, char_data.char)
        char_i = char_i + 1
      end
      GuiLayoutEnd(gui)
      y_offset = y_offset + 12
    end
    -- /Text
    GuiIdPop(gui)
    wait(0)
  end)
  -- Advancde the state logic etc
  async(function()
    for i=1, 32 do
      dialog.transition_state = dialog.transition_state + (1 / 32)
      wait(0)
    end
    dialog.fade_in_portrait = 32
    for i=32, 1, -1 do
      dialog.fade_in_portrait = dialog.fade_in_portrait - 1
      wait(3)
    end
    print("dialog.fade_in_portrait: " .. tostring(dialog.fade_in_portrait))
    local wave = false
    local i = 1

    while i <= #messages[1].message do
      local char = messages[1].message:sub(i, i)
      if char == "\n" then
        table.insert(lines, {})
        current_line = lines[#lines]
      elseif char == "*" then
        wave = not wave
      else
        table.insert(current_line, { char = char, wave = wave })
      end
      i = i + 1
      wait(5)
    end
  end)
end
