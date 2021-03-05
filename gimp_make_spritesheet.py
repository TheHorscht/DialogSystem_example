img = gimp.image_list()[0]
for y in range(13):
  for x in range(12):
    img.layers[y * 12 + x].set_offsets(x * 64, y * 64)