local player = GetUpdatedEntityID()
local controls_component = EntityGetFirstComponent(player, "ControlsComponent")
local mButtonFrameLeft = ComponentGetValue2(controls_component, "mButtonFrameLeft")
local mButtonFrameRight = ComponentGetValue2(controls_component, "mButtonFrameRight")
local current_frame = GameGetFrameNum()
local left_pressed = mButtonFrameLeft == current_frame
local right_pressed = mButtonFrameRight == current_frame
cooldown_frames_left = (cooldown_frames_left or 0) - 1
 
function dash(entity, force)
  local character_data_component = EntityGetFirstComponent(entity, "CharacterDataComponent")
  local vx, vy = ComponentGetValue2(character_data_component, "mVelocity")
  ComponentSetValue2(character_data_component, "mVelocity", vx + force, vy)
  cooldown_frames_left = 120
end
 

if left_pressed and cooldown_frames_left < 0 then
  if last_frame_left_pressed ~= nil and (current_frame - last_frame_left_pressed < 30) then
    dash(player, -400)
    last_frame_left_pressed = nil
  else
    last_frame_left_pressed = current_frame
  end
end
 
if right_pressed and cooldown_frames_left < 0 then
  if last_frame_right_pressed ~= nil and (current_frame - last_frame_right_pressed < 30) then
    dash(player, 400)
    last_frame_right_pressed = nil
  else
    last_frame_right_pressed = current_frame
  end
end
