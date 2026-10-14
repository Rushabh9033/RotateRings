from PIL import Image, ImageDraw

ref = Image.open('ALL 2to100 levels/26.jpeg')
ref_w, ref_h = ref.size
target_h = int(ref_h * 720.0 / ref_w)
ref_scaled = ref.resize((720, target_h), Image.LANCZOS)

godot = Image.open('_godot_test_out/level26_root.png')
crop_y1, crop_y2 = 180, 1150
ref_crop = ref_scaled.crop((0, crop_y1, 720, crop_y2))
godot_crop = godot.crop((0, crop_y1, 720, crop_y2))

w, h = ref_crop.size
combined = Image.new('RGB', (w * 2 + 20, h + 50), (245, 240, 230))
draw = ImageDraw.Draw(combined)

combined.paste(ref_crop, (0, 50))
combined.paste(godot_crop, (w + 20, 50))

draw.text((w // 2 - 80, 15), "REFERENCE (Level 26)", fill=(30, 30, 30))
draw.text((w + 20 + w // 2 - 80, 15), "GODOT ENGINE RENDER", fill=(30, 30, 30))

combined.save('_godot_test_out/side_by_side_26.png')
print('Saved _godot_test_out/side_by_side_26.png')
