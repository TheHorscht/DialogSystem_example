dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")
local Color = dofile_once("mods/DialogSystem/lib/color.lua")

local dialog_box_width = 300
local dialog_box_height = 70
local line_height = 10

-- local dialog = {}

dialog_system = {
  LEFT = 1,
  RIGHT = 2,
}

gui = GuiCreate()
-- dialog = nil

local routines = {}

dialog_system.open_dialog = function(messages)
  local dialog = {
    transition_state = 0,
    messages = messages,
    lines = {{}},
  }
  dialog.current_line = dialog.lines[1]
  dialog.show = function(message)
    dialog.messages = { message }
    dialog.lines = {{}}
  end

  -- "Kill" currently running routines
  for k, v in pairs(routines) do
    -- WAITING_ON_TIME[v] = nil
    -- routines[k] = nil
    cancel(v)
  end

  -- local lines = {{}}
  -- local current_line = lines[1]
  local render_gui = true
  -- Render the GUI
  routines.gui = async(function()
    while render_gui do
      GuiStartFrame(gui)
      local screen_width, screen_height = GuiGetScreenDimensions(gui)
      local width = dialog.transition_state * dialog_box_width
      local height = dialog.transition_state * dialog_box_height
      local x, y = screen_width/2 - width/2, screen_height - 100 - height/2
      y = y + (height/2) - (64/2)
      x = x + 3
      GuiIdPushString(gui, "dialog_box")
      GuiZSetForNextWidget(gui, 2)
      GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
      if dialog.fade_in_portrait then
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
      for i, line in ipairs(dialog.lines) do
        GuiLayoutBeginHorizontal(gui, x + 72, y, true)
        for i2, char_data in ipairs(line) do
          local wave_offset_y = 0
          if char_data.wave then
            local color = Color:new(math.cos(char_i * 0.14 + GameGetFrameNum() * 0.03) * 360, 0.5, 0.5)
            local r, g, b = color:get_rgb()
            GuiColorSetForNextWidget(gui, r, g, b, 1)
            wave_offset_y = math.sin(char_i * 0.5 + GameGetFrameNum() * 0.1) * 1
          end
          if char_data.blink then
            local l = math.sin(GameGetFrameNum() * 0.15) *  0.3 + 0.7
            GuiColorSetForNextWidget(gui, l, l, l, 1)
          end
          GuiText(gui, -2, y_offset + wave_offset_y, char_data.char)
          char_i = char_i + 1
        end
        GuiLayoutEnd(gui)
        y_offset = y_offset + line_height
      end
      -- /Text
      for i, v in ipairs(dialog.show_options and messages[1].options or {}) do
        if GuiButton(gui, 5 + i, x + 72, y + i * line_height + 30, "[ " .. v.text .. " ]") then
          v.func(dialog)
        end
      end
      GuiIdPop(gui)
      wait(0)
    end
  end)
  -- Advance the state logic etc
  routines.logic = async(function()
    for i=1, 32 do
      dialog.transition_state = dialog.transition_state + (1 / 32)
      wait(0)
    end
    dialog.fade_in_portrait = 32
    for i=32, 1, -1 do
      dialog.fade_in_portrait = dialog.fade_in_portrait - 1
      wait(1)
    end

    -- wait_or_abort(1, false)

    local wave, blink = false, false
    local delay = 3
    local i = 1

    while i <= #messages[1].message do
      local char = messages[1].message:sub(i, i)
      if char == "\n" then
        table.insert(dialog.lines, {})
        dialog.current_line = dialog.lines[#dialog.lines]
      elseif char == "~" then
        wave = not wave
      elseif char == "*" then
        blink = not blink
      elseif char == "{" then
        -- local command, param1 = string.gmatch("hello{@delay 5}", "@(%w+)%s+(%d)")()
        -- Look ahead 20 characters and get that substring
        local str = messages[1].message:sub(i, i + 20)
        local command, param1 = string.gmatch(str, "@(%w+)%s+(%d+)")()
        if command then
          if command == "delay" then
            delay = tonumber(param1)
          elseif command == "pause" then
            wait(tonumber(param1))
          end
          i = i + string.find(str, "}") - 1
        end
      else
        table.insert(dialog.current_line, { char = char, wave = wave, blink = blink })
      end
      i = i + 1
      wait(delay)
    end
    wait(30)
    dialog.show_options = true
  end)
end













-- dofile_once("data/scripts/lib/coroutines.lua")
-- dofile_once("data/scripts/lib/utilities.lua")
-- local Color = dofile_once("mods/DialogSystem/lib/color.lua")

-- local dialog_box_width = 300
-- local dialog_box_height = 70
-- local line_height = 10

-- local function wait_or_abort(frames, condition)
--   if not condition then
--     -- local co = coroutine.running()
--     error("stop")
--   else
--     wait(frames)
--   end
-- end

-- dialog_system = {
--   LEFT = 1,
--   RIGHT = 2,
-- }

-- gui = GuiCreate()
-- dialog = nil

-- dialog_system.open_dialog = function(messages)
--   dialog = {
--     transition_state = 0,
--     messages = messages
--   }

--   local lines = {{}}
--   local current_line = lines[1]
--   local render_gui = true
--   -- Render the GUI
--   async(function()
--     while render_gui do
--       GuiStartFrame(gui)
--       local screen_width, screen_height = GuiGetScreenDimensions(gui)
--       local width = dialog.transition_state * dialog_box_width
--       local height = dialog.transition_state * dialog_box_height
--       local x, y = screen_width/2 - width/2, screen_height - 100 - height/2
--       y = y + (height/2) - (64/2)
--       x = x + 3
--       GuiIdPushString(gui, "dialog_box")
--       GuiZSetForNextWidget(gui, 2)
--       GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - 100 - height/2, width, height)
--       if dialog.fade_in_portrait then
--         GuiZSetForNextWidget(gui, 1)
--         GuiImage(gui, 2, x, y, "mods/DialogSystem/files/portrait.png", 1, 1, 1, 0)
--         GuiZSetForNextWidget(gui, 0)
--         GuiImage(gui, 3, x, y, "mods/DialogSystem/files/transition.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause, "anim_" .. tostring(dialog.fade_in_portrait))
--         GuiZSetForNextWidget(gui, -1)
--         GuiImage(gui, 4, x, y, "mods/DialogSystem/files/border.png", 1, 1, 1, 0)
--       end
--       -- Render text
--       local y_offset = 0
--       local char_i = 1
--       for i, line in ipairs(lines) do
--         GuiLayoutBeginHorizontal(gui, x + 72, y, true)
--         for i2, char_data in ipairs(line) do
--           local wave_offset_y = 0
--           if char_data.wave then
--             local color = Color:new(math.cos(char_i * 0.14 + GameGetFrameNum() * 0.03) * 360, 0.5, 0.5)
--             local r, g, b = color:get_rgb()
--             GuiColorSetForNextWidget(gui, r, g, b, 1)
--             wave_offset_y = math.sin(char_i * 0.5 + GameGetFrameNum() * 0.1) * 1
--           end
--           if char_data.blink then
--             local l = math.sin(GameGetFrameNum() * 0.15) *  0.3 + 0.7
--             GuiColorSetForNextWidget(gui, l, l, l, 1)
--           end
--           GuiText(gui, -2, y_offset + wave_offset_y, char_data.char)
--           char_i = char_i + 1
--         end
--         GuiLayoutEnd(gui)
--         y_offset = y_offset + line_height
--       end
--       -- /Text
--       for i, v in ipairs(dialog.show_options and messages[1].options or {}) do
--         GuiButton(gui, 5 + i, x + 72, y + i * line_height + 30, "[ " .. v .. " ]")
--       end
--       GuiIdPop(gui)
--       wait(0)
--     end
--   end)
--   -- Advance the state logic etc
--   async(function()
--     for i=1, 32 do
--       dialog.transition_state = dialog.transition_state + (1 / 32)
--       wait(0)
--     end
--     dialog.fade_in_portrait = 32
--     for i=32, 1, -1 do
--       dialog.fade_in_portrait = dialog.fade_in_portrait - 1
--       wait(1)
--     end

--     wait_or_abort(1, false)

--     local wave, blink = false, false
--     local delay = 3
--     local i = 1

--     while i <= #messages[1].message do
--       local char = messages[1].message:sub(i, i)
--       if char == "\n" then
--         table.insert(lines, {})
--         current_line = lines[#lines]
--       elseif char == "~" then
--         wave = not wave
--       elseif char == "*" then
--         blink = not blink
--       elseif char == "{" then
--         -- local command, param1 = string.gmatch("hello{@delay 5}", "@(%w+)%s+(%d)")()
--         -- Look ahead 20 characters and get that substring
--         local str = messages[1].message:sub(i, i + 20)
--         local command, param1 = string.gmatch(str, "@(%w+)%s+(%d+)")()
--         if command then
--           if command == "delay" then
--             delay = tonumber(param1)
--           elseif command == "pause" then
--             wait(tonumber(param1))
--           end
--           i = i + string.find(str, "}") - 1
--         end
--       else
--         table.insert(current_line, { char = char, wave = wave, blink = blink })
--       end
--       i = i + 1
--       wait(delay)
--     end
--     wait(30)
--     dialog.show_options = true
--   end)
-- end
