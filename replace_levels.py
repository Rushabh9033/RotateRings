with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "r") as f:
    text = f.read()

# We need to cut out everything between "13:" and "_:"
import re
new_text = re.sub(r'\t\t13:\n.*?(?=\t\t_:)', '', text, flags=re.DOTALL)

with open("levels_13_to_50_fixed.gd", "r") as f:
    new_levels = f.read()

new_text = new_text.replace('\t\t_:', new_levels + '\t\t_:')

with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "w") as f:
    f.write(new_text)
