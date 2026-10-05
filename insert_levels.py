with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "r") as f:
    lines = f.readlines()
    
with open("levels_13_to_50.gd", "r") as f:
    new_levels = f.read()

# Find the fallback case
insert_idx = -1
for i, line in enumerate(lines):
    if line.strip() == "_:":
        insert_idx = i
        break

if insert_idx != -1:
    lines.insert(insert_idx, new_levels + "\n")

text = "".join(lines)
text = text.replace("return 12", "return 50")

with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "w") as f:
    f.write(text)
