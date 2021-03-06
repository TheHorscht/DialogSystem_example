local function inject_path(file, path)
  local content = ModTextFileGetContent(file)
  content = content:gsub("%%PATH%%", path)
  ModTextFileSetContent(file, content)
end

return function(lib_path, images)
  local root_path = "mods/" .. lib_path:gsub("([^/])$","%1/") --  Add a slash at the end if it doesn't already exist
  ModRegisterAudioEventMappings(root_path .. "audio/GUIDs.txt")
  inject_path(root_path .. "dialog_system.lua", root_path)
  inject_path(root_path .. "transition.xml", root_path)

  local image_inserts = ""
  for name, file_path in pairs(images or {}) do
    image_inserts = image_inserts .. name .. " = \"" .. file_path .. "\",\n"
  end
  ModTextFileSetContent("data/virtual/DialogSystem_config.lua", [[
    return {
      images = {]] .. image_inserts .. [[},
      dialog_box_y = 50,
      dialog_box_width = 300,
      dialog_box_height = 70,
      distance_to_close = 15,
    }    
  ]])
end
