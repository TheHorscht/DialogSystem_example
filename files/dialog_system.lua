dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")
local Color = dofile_once("mods/DialogSystem/lib/color.lua")

local dialog_box_y = 50
local dialog_box_width = 300
local dialog_box_height = 70
local line_height = 10
local distance_to_close = 15

dialog_system = {
  LEFT = 1,
  RIGHT = 2,
  images = { ruby = "mods/DialogSystem/files/ruby.png" }
}

-- DEBUG_SKIP_ANIMATIONS = true

gui = GuiCreate()

local routines = {}

dialog_system.open_dialog = function(message)
  -- Remove whitespace before and after every line
  -- for i, msg in ipairs(messages) do
    message.text = message.text:gsub("^%s*", ""):gsub("\n%s*", "\n"):gsub("%s*(?:\n)", "")
  -- end
  
  local entity_id = GetUpdatedEntityID()
  local x, y = EntityGetTransform(entity_id)

  local dialog = {
    transition_state = 0,
    fade_in_portrait = -1,
    message = message,
    lines = {{}},
    opened_at_position = { x = x, y = y },
    is_open = true,
  }
  dialog.current_line = dialog.lines[1]
  dialog.show = function(message)
    dialog.message = message
    dialog.lines = {{}}
    dialog.current_line = dialog.lines[1]
    dialog.show_options = false
    routines.logic.restart()
  end

  dialog.is_too_far = function()
    local player = EntityGetWithTag("player_unit")[1]
    local px, py = EntityGetTransform(player)
    local function get_distance( x1, y1, x2, y2 )
      local result = math.sqrt( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 )
      return result
    end
    
    return get_distance(dialog.opened_at_position.x, dialog.opened_at_position.y, px, py) > distance_to_close
  end

  dialog.close = function()
    if dialog.closing then return end
    if routines.logic then
      routines.logic.stop()
    end
    dialog.closing = true
    dialog.lines = {{}}
    dialog.current_line = dialog.lines[1]
    dialog.show_options = false
    GamePrint("closing dialog")
    async(function()
      while dialog.fade_in_portrait > -1 do
        dialog.fade_in_portrait = dialog.fade_in_portrait - 1
        wait(0)
      end
      while dialog.transition_state > 0 do
        dialog.transition_state = dialog.transition_state - (1 / 32)
        wait(0)
      end
      dialog.is_open = false
    end)
  end

  -- "Kill" currently running routines
  for k, v in pairs(routines) do
    -- WAITING_ON_TIME[v] = nil
    -- routines[k] = nil
    print("Trying to cancel: " .. tostring(k) .. " - " ..  tostring(v))
    v.stop()
  end

  -- local lines = {{}}
  -- local current_line = lines[1]

  -- Render the GUI
  routines.gui = async(function()
    while dialog.is_open do
      if dialog.is_too_far() then
        dialog.close()
      end
      GuiStartFrame(gui)
      local screen_width, screen_height = GuiGetScreenDimensions(gui)
      local width = dialog.transition_state * dialog_box_width
      local height = dialog.transition_state * dialog_box_height
      local x, y = screen_width/2 - width/2, screen_height - height/2
      -- x and y are the center of the dialog box and will be used to draw text and portaits etc
      y = y - dialog_box_height / 2 + 3 - dialog_box_y
      -- y = y + (height/2) - (64/2) + dialog_box_y
      x = x + 3
      GuiIdPushString(gui, "dialog_box")
      GuiZSetForNextWidget(gui, 2)
      GuiImageNinePiece(gui, 1, screen_width/2 - width/2, screen_height - dialog_box_y - dialog_box_height/2 - height/2, width, height)
      if dialog.fade_in_portrait > -1 then
        GuiZSetForNextWidget(gui, 1)
        -- GuiImage( gui:obj, id:int, x:number, y:number, sprite_filename:string, alpha:number = 1, scale:number = 1, scale_y:number = 0, rotation:number = 0, rect_animation_playback_type:int = GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndHide, rect_animation_name:string = "" ) ['scale' will be used for 'scale_y' if 'scale_y' equals 0.]
        GuiImage(gui, 2, x, y, "mods/DialogSystem/files/morshu.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.Loop, "morshu")
        -- GuiImage(gui, 2, x, y, "mods/DialogSystem/files/portrait.png", 1, 1, 1, 0)
        GuiZSetForNextWidget(gui, 0)
        GuiImage(gui, 3, x, y, "mods/DialogSystem/files/transition.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause, "anim_" .. tostring(dialog.fade_in_portrait))
        GuiZSetForNextWidget(gui, -1)
        GuiImage(gui, 4, x, y, "mods/DialogSystem/files/border.png", 1, 1, 1, 0)
      end
      -- Render text
      local y_offset = 0
      local char_i = 1
      for i, line in ipairs(dialog.lines) do
        GuiLayoutBeginHorizontal(gui, x + 72, y - 1, true)
        for i2, char_data in ipairs(line) do
          local wave_offset_y = 0
          local shake_offset = { x = 0, y = 0 }

          local r, g, b, a = unpack(char_data.color)
          local absolute_position = false

          if char_data.shake then
            shake_offset.x = (1 - math.random() * 2) * 0.7
            shake_offset.y = (1 - math.random() * 2) * 0.7
            -- Draw an invisible version of the text just so we can get the location where it would be drawn normally
            GuiColorSetForNextWidget(gui, 1, 1, 1, 0.001) --  0 alpha doesn't work, is bug
            GuiText(gui, -2, y_offset + wave_offset_y, char_data.char)
            local _, _, _, x, y, _ ,_ , draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
            shake_offset.x = shake_offset.x + x
            shake_offset.y = shake_offset.y + y
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NoLayouting)
            absolute_position = true
          end
          if char_data.wave then
            local color = Color:new(math.cos(char_i * 0.14 + GameGetFrameNum() * 0.03) * 360, 0.5, 0.5)
            r, g, b = color:get_rgb()
            -- GuiColorSetForNextWidget(gui, r, g, b, 1)
            wave_offset_y = math.sin(char_i * 0.5 + GameGetFrameNum() * 0.1) * 1
          end
          if char_data.blink then
            a = math.sin(GameGetFrameNum() * 0.2) *  0.3 + 0.7
          end
          GuiColorSetForNextWidget(gui, r, g, b, a)
          GuiText(gui, (absolute_position and 0 or -2) + shake_offset.x, (absolute_position and 0 or y_offset) + wave_offset_y + shake_offset.y, char_data.char)
          char_i = char_i + 1
        end
        GuiLayoutEnd(gui)
        y_offset = y_offset + line_height
      end
      -- /Text
      -- Dialog options
      if dialog.show_options then
        if dialog.message.options then
          local num_options = #dialog.message.options
          for i, v in ipairs(dialog.message.options) do
            if GuiButton(gui, 5 + i, x + 70, y + dialog_box_height - (num_options - i + 1) * line_height - 7, "[ " .. v.text .. " ]") then
              v.func(dialog)
            end
          end
        else
          if GuiButton(gui, 6, x + 70, y + dialog_box_height - line_height - 7, "[ End ]") then
            dialog.close()
          end
        end
      end
      -- /Dialog options
      GuiIdPop(gui)
      wait(0)
    end
  end)

  -- Advance the state logic etc
  routines.logic = async(function()
    if DEBUG_SKIP_ANIMATIONS then
      dialog.transition_state = 1
      dialog.fade_in_portrait = 32
    end
    while dialog.transition_state < 1 do
    -- for i=1, 32 do
      dialog.transition_state = dialog.transition_state + (1 / 32)
      wait(0)
    end
    dialog.transition_state = 1
    -- for i=32, 1, -1 do
    while dialog.fade_in_portrait < 32 do
      dialog.fade_in_portrait = dialog.fade_in_portrait + 1
      wait(1)
    end
    dialog.fade_in_portrait = 32
    

    local color = { 1, 1, 1, 1 }
    local wave, blink, shake = false, false, false
    local delay = 3
    local i = 1
    
    while i <= #dialog.message.text do
      local char = dialog.message.text:sub(i, i)
      if char == "\n" then
        table.insert(dialog.lines, {})
        dialog.current_line = dialog.lines[#dialog.lines]
      elseif char == "~" then
        wave = not wave
      elseif char == "*" then
        blink = not blink
      elseif char == "#" then
        shake = not shake
      elseif char == "{" then
        -- local command, param1 = string.gmatch("hello{@delay 5}", "@(%w+)%s+(%d)")()
        -- Look ahead 20 characters and get that substring
        local str = dialog.message.text:sub(i, i + 20)
        local command, param1 = string.gmatch(str, "@(%w+)%s+([^}]+)")()
        if command then
          if command == "delay" then
            delay = tonumber(param1)
          elseif command == "pause" then
            wait(tonumber(param1))
          elseif command == "color" then
            local rgb = tonumber(param1, 16)
            color[1] = bit.band(bit.rshift(rgb, 16), 0xFF) / 255
            color[2] = bit.band(bit.rshift(rgb, 8), 0xFF) / 255
            color[3] = bit.band(rgb, 0xFF) / 255
          end
          i = i + string.find(str, "}") - 1
        end
      else
        local color_copy = {unpack(color)}
        table.insert(dialog.current_line, { char = char, wave = wave, blink = blink, shake = shake, color = color_copy })
        if char ~= " " and frame_last_played_sound ~= GameGetFrameNum() then
          frame_last_played_sound = GameGetFrameNum()
          local cx, cy = GameGetCameraPos()
          -- GamePlaySound("mods/DialogSystem/audio/dialog_system.bank", "talking_sounds/" .. GlobalsGetValue("sound", "sans"), GameGetCameraPos())
          local pan = GameGetFrameNum() % 120 < 60 and -1 or 1
          -- local add = pan < 0 and "_2" or ""
          -- local add = ""
          -- GamePrint(add)
          GamePlaySound("mods/DialogSystem/audio/dialog_system.bank", "talking_sounds/" .. GlobalsGetValue("sound", "sans"), cx - 400 * pan, cy)
          -- GamePlaySound("mods/DialogSystem/audio/dialog_system.bank", "snd_mod/create", GameGetCameraPos())
        end
      end
      i = i + 1
      if delay > 0 then
        wait(delay)
      end
    end
    wait(30)
    dialog.show_options = true



  end)
  return dialog
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
