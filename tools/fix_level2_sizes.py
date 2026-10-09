import json
data = json.load(open(r'D:\AI secound Brain\RotateRings\data\user_levels\2.json'))
# Make ring sizes visibly different: orange biggest, purple medium, cyan smallest.
# This matches the visual hierarchy in 2.jpeg.
data['pieces'][0]['radius'] = 96
data['pieces'][0]['radius_y'] = 96
data['pieces'][1]['radius'] = 65
data['pieces'][1]['radius_y'] = 65
data['pieces'][2]['radius'] = 75
data['pieces'][2]['radius_y'] = 75
# Fix cyan gap: it should face LEFT (180 deg world) toward orange, so the cuff
# is between orange's right tip and cyan's left tip.
data['pieces'][1]['gaps'][0]['center_angle_deg'] = 180
with open(r'D:\AI secound Brain\RotateRings\data\user_levels\2.json', 'w') as f:
    json.dump(data, f, indent=2)
print('Updated Level 2 ring sizes:')
for i, p in enumerate(data['pieces']):
    print(f"  {p['id']:12s}  radius={p['radius']:3d}  gap_deg={p['gaps'][0]['center_angle_deg']:3d}")
