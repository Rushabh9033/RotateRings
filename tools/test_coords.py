levels_data = {
    5: {
        'pieces': {
            'ring_0': (250, 340, 76),
            'ring_1': (440, 370, 76),
            'ring_2': (320, 520, 76),
            'ring_3': (140, 660, 76),
            'ring_4': (360, 710, 76),
            'ring_5': (280, 890, 76),
            'ring_6': (550, 600, 76),
        },
        'links': [
            ('ring_3', 'ring_2'),
            ('ring_2', 'ring_1'),
            ('ring_2', 'ring_4'),
            ('ring_1', 'ring_0'),
            ('ring_4', 'ring_6'),
            ('ring_4', 'ring_5'),
        ]
    },
    6: {
        'pieces': {
            'ring_0': (220, 360, 72),
            'ring_1': (500, 360, 72),
            'ring_2': (360, 500, 68),
            'ring_3': (140, 540, 72),
            'ring_4': (580, 540, 72),
            'ring_5': (360, 680, 72),
            'ring_6': (220, 840, 72),
            'ring_7': (500, 840, 72),
            'ring_8': (360, 980, 72),
        },
        'links': [
            ('ring_2', 'ring_0'),
            ('ring_2', 'ring_1'),
            ('ring_0', 'ring_3'),
            ('ring_1', 'ring_4'),
            ('ring_5', 'ring_3'),
            ('ring_5', 'ring_4'),
            ('ring_8', 'ring_6'),
            ('ring_8', 'ring_7'),
        ]
    },
    7: {
        'pieces': {
            'ring_0': (220, 380, 76),
            'ring_1': (500, 380, 76),
            'ring_2': (360, 520, 76),
            'ring_3': (220, 680, 76),
            'ring_4': (500, 680, 76),
            'ring_5': (360, 820, 76),
        },
        'links': [
            ('ring_2', 'ring_0'),
            ('ring_2', 'ring_1'),
            ('ring_5', 'ring_3'),
            ('ring_5', 'ring_4'),
        ]
    },
    9: {
        'pieces': {
            'ring_0': (140, 520, 76),
            'ring_1': (250, 690, 76),
            'ring_2': (360, 520, 76),
            'ring_3': (470, 690, 76),
            'ring_4': (580, 520, 76),
        },
        'links': [
            ('ring_0', 'ring_1'),
            ('ring_2', 'ring_1'),
            ('ring_2', 'ring_3'),
            ('ring_4', 'ring_3'),
        ]
    },
    10: {
        'pieces': {
            'ring_0': (360, 620, 80),
            'ring_1': (160, 620, 76),
            'ring_2': (560, 620, 76),
        },
        'links': [
            ('ring_0', 'ring_1'),
            ('ring_0', 'ring_2'),
        ]
    },
    11: {
        'pieces': {
            'ring_0': (360, 422, 76),
            'ring_1': (532, 521, 76),
            'ring_2': (532, 719, 76),
            'ring_3': (360, 818, 76),
            'ring_4': (188, 719, 76),
            'ring_5': (188, 521, 76),
        },
        'links': [
            ('ring_0', 'ring_1'),
            ('ring_1', 'ring_2'),
            ('ring_2', 'ring_3'),
            ('ring_3', 'ring_4'),
            ('ring_4', 'ring_5'),
        ]
    },
    12: {
        'pieces': {
            'ring_0': (220, 460, 76),
            'ring_1': (500, 460, 76),
            'ring_2': (120, 630, 76),
            'ring_3': (360, 600, 76),
            'ring_4': (600, 630, 76),
            'ring_5': (360, 805, 76),
        },
        'links': [
            ('ring_0', 'ring_2'),
            ('ring_1', 'ring_4'),
            ('ring_3', 'ring_0'),
            ('ring_3', 'ring_1'),
            ('ring_5', 'ring_3'),
        ]
    }
}

for lvl, data in levels_data.items():
    p = data['pieces']
    links = data['links']
    issues = []
    for f, t in links:
        p1, p2 = p[f], p[t]
        d = ((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)**0.5
        s = d - (p1[2] + p2[2])
        if s < 30.0:
            issues.append(f'SHORT STEM: {f} -> {t}: dist={d:.1f}, stem={s:.1f}px')

    keys = list(p.keys())
    for i in range(len(keys)):
        for j in range(i+1, len(keys)):
            k1, k2 = keys[i], keys[j]
            is_linked = (k1, k2) in links or (k2, k1) in links
            if not is_linked:
                p1, p2 = p[k1], p[k2]
                d = ((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)**0.5
                c = d - (p1[2] + p2[2])
                if c < 15.0:
                    issues.append(f'COLLISION: {k1} & {k2}: dist={d:.1f}, clearance={c:.1f}px')

    if issues:
        print(f'[FAIL] Level {lvl:02d}:')
        for iss in issues:
            print(f'   {iss}')
    else:
        print(f'[OK]   Level {lvl:02d}: Perfectly balanced (all stems >= 30px, clearance >= 15px)')
