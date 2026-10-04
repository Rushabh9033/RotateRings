import re

with open('data/level_database.gd', 'r') as f:
    content = f.read()

# Match each level case
matches = list(re.finditer(r'(\d+):\s*#', content))
print(f'Found {len(matches)} level definitions\n')

for idx, match in enumerate(matches):
    lvl_num = int(match.group(1))
    start_pos = match.start()
    end_pos = matches[idx + 1].start() if idx + 1 < len(matches) else len(content)
    lvl_code = content[start_pos:end_pos]

    # Find pieces
    piece_matches = re.findall(r'PieceDefinitionScript\.new\(&"([^"]+)",\s*Vector2\((\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?)\),\s*(\d+(?:\.\d+)?)', lvl_code)
    # Find links
    link_matches = re.findall(r'LinkDefinitionScript\.new\(&"[^"]+",\s*&"([^"]+)",\s*&"([^"]+)"', lvl_code)

    p_map = {p[0]: (float(p[1]), float(p[2]), float(p[3])) for p in piece_matches}
    issues = []

    for from_id, to_id in link_matches:
        if from_id in p_map and to_id in p_map:
            p1 = p_map[from_id]
            p2 = p_map[to_id]
            dist = ((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)**0.5
            stem = dist - (p1[2] + p2[2])
            if stem < 28.0:
                issues.append(f'SHORT STEM: {from_id} -> {to_id} | dist={dist:.1f}px, stem={stem:.1f}px')

    p_keys = list(p_map.keys())
    for a in range(len(p_keys)):
        for b in range(a + 1, len(p_keys)):
            k1, k2 = p_keys[a], p_keys[b]
            p1, p2 = p_map[k1], p_map[k2]
            dist = ((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)**0.5
            clearance = dist - (p1[2] + p2[2])
            is_linked = any((from_id == k1 and to_id == k2) or (from_id == k2 and to_id == k1) for from_id, to_id in link_matches)
            if clearance < 10.0 and not is_linked:
                issues.append(f'COLLISION: {k1} & {k2} | dist={dist:.1f}px, clearance={clearance:.1f}px')

    if issues:
        print(f'[FAIL] Level {lvl_num:02d}:')
        for iss in issues:
            print(f'   {iss}')
    else:
        print(f'[OK]   Level {lvl_num:02d}: Clean spacing (all stems >= 28px, zero collisions)')
