import re, math

with open(r'd:\AI secound Brain\RotateRings\data\level_database.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's extract each case block:
level_chunks = re.split(r'\n\t\t(\d+):', text)
print(f'Total chunks found: {len(level_chunks)}')

for i in range(1, len(level_chunks), 2):
    lvl_num = level_chunks[i]
    lvl_code = level_chunks[i+1]
    title_m = re.search(r'def\.title\s*=\s*"([^"]+)"', lvl_code)
    title = title_m.group(1) if title_m else "Unknown"
    pieces = re.findall(r'PieceDefinitionScript\.new\(&"([^"]+)",\s*Vector2\(([^)]+)\),\s*([0-9.]+),\s*([0-9.]+),\s*Color\("([^"]+)"\),\s*([0-9.]+)', lvl_code)
    links = re.findall(r'LinkDefinitionScript\.new\(&"([^"]+)",\s*&"([^"]+)",\s*&"([^"]+)"', lvl_code)
    print(f"Level {lvl_num}: '{title}' | Pieces: {len(pieces)} | Links: {len(links)}")
    for p in pieces:
        print(f"   Piece: {p[0]} @ ({p[1]}) r={p[2]} start_angle={p[5]}")
    for l in links:
        print(f"   Link: {l[0]} from {l[1]} -> {l[2]}")
