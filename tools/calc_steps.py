import math

def fposmod(a, b):
    return (a % b + b) % b

def angle_deg(from_p, to_p):
    return fposmod(math.degrees(math.atan2(to_p[1] - from_p[1], to_p[0] - from_p[0])), 360.0)

# Level 5
p5 = {
    'ring_0': (250, 340), # Orange
    'ring_1': (440, 370), # Cyan
    'ring_2': (320, 520), # Purple
    'ring_3': (140, 660), # Red
    'ring_4': (360, 710), # LightGreen
    'ring_5': (280, 890), # DarkBlue
    'ring_6': (550, 600), # DarkGreen
}

print('=== Level 5 Steps ===')
print('ring_0 target:', round(angle_deg(p5['ring_0'], p5['ring_1']), 1))
print('ring_6 target:', round(angle_deg(p5['ring_6'], p5['ring_4']), 1))
print('ring_5 target:', round(angle_deg(p5['ring_5'], p5['ring_4']), 1))
print('ring_1 target:', round(angle_deg(p5['ring_1'], p5['ring_2']), 1))
print('ring_4 target:', round(angle_deg(p5['ring_4'], p5['ring_2']), 1))
print('ring_2 target:', round(angle_deg(p5['ring_2'], p5['ring_3']), 1))

# Level 6
p6 = {
    'ring_0': (220, 360),
    'ring_1': (500, 360),
    'ring_2': (360, 500), # Center closed
    'ring_3': (140, 540),
    'ring_4': (580, 540),
    'ring_5': (360, 680),
    'ring_6': (220, 840),
    'ring_7': (500, 840),
    'ring_8': (360, 980),
}
# links: r2->r0, r2->r1, r0->r3, r1->r4, r5->r3, r5->r4, r8->r6, r8->r7
print('\n=== Level 6 Steps ===')
print('ring_6 target (to r8):', round(angle_deg(p6['ring_6'], p6['ring_8']), 1))
print('ring_7 target (to r8):', round(angle_deg(p6['ring_7'], p6['ring_8']), 1))
print('ring_3 target (to r5):', round(angle_deg(p6['ring_3'], p6['ring_5']), 1))
print('ring_3 target (to r0):', round(angle_deg(p6['ring_3'], p6['ring_0']), 1))
print('ring_4 target (to r5):', round(angle_deg(p6['ring_4'], p6['ring_5']), 1))
print('ring_4 target (to r1):', round(angle_deg(p6['ring_4'], p6['ring_1']), 1))
print('ring_0 target (to r2):', round(angle_deg(p6['ring_0'], p6['ring_2']), 1))
print('ring_1 target (to r2):', round(angle_deg(p6['ring_1'], p6['ring_2']), 1))

# Level 7
p7 = {
    'ring_0': (220, 380),
    'ring_1': (500, 380),
    'ring_2': (360, 520),
    'ring_3': (220, 680),
    'ring_4': (500, 680),
    'ring_5': (360, 820),
}
print('\n=== Level 7 Steps ===')
print('ring_0 target (to r2):', round(angle_deg(p7['ring_0'], p7['ring_2']), 1))
print('ring_1 target (to r2):', round(angle_deg(p7['ring_1'], p7['ring_2']), 1))
print('ring_3 target (to r5):', round(angle_deg(p7['ring_3'], p7['ring_5']), 1))
print('ring_4 target (to r5):', round(angle_deg(p7['ring_4'], p7['ring_5']), 1))

# Level 9
p9 = {
    'ring_0': (140, 520),
    'ring_1': (250, 690),
    'ring_2': (360, 520),
    'ring_3': (470, 690),
    'ring_4': (580, 520),
}
# links: r0->r1, r2->r1, r2->r3, r4->r3
print('\n=== Level 9 Steps ===')
print('ring_1 target (to r0):', round(angle_deg(p9['ring_1'], p9['ring_0']), 1))
print('ring_1 target (to r2):', round(angle_deg(p9['ring_1'], p9['ring_2']), 1))
print('ring_3 target (to r4):', round(angle_deg(p9['ring_3'], p9['ring_4']), 1))
print('ring_3 target (to r2):', round(angle_deg(p9['ring_3'], p9['ring_2']), 1))

# Level 10
p10 = {
    'ring_0': (360, 620),
    'ring_1': (160, 620),
    'ring_2': (560, 620),
}
print('\n=== Level 10 Steps ===')
print('ring_1 target (to r0):', round(angle_deg(p10['ring_1'], p10['ring_0']), 1))
print('ring_2 target (to r0):', round(angle_deg(p10['ring_2'], p10['ring_0']), 1))

# Level 11
p11 = {
    'ring_0': (360, 422),
    'ring_1': (532, 521),
    'ring_2': (532, 719),
    'ring_3': (360, 818),
    'ring_4': (188, 719),
    'ring_5': (188, 521),
}
print('\n=== Level 11 Steps ===')
print('ring_1 target (to r0):', round(angle_deg(p11['ring_1'], p11['ring_0']), 1))
print('ring_2 target (to r1):', round(angle_deg(p11['ring_2'], p11['ring_1']), 1))
print('ring_3 target (to r2):', round(angle_deg(p11['ring_3'], p11['ring_2']), 1))
print('ring_4 target (to r3):', round(angle_deg(p11['ring_4'], p11['ring_3']), 1))
print('ring_5 target (to r4):', round(angle_deg(p11['ring_5'], p11['ring_4']), 1))

# Level 12
p12 = {
    'ring_0': (220, 460),
    'ring_1': (500, 460),
    'ring_2': (120, 630),
    'ring_3': (360, 600),
    'ring_4': (600, 630),
    'ring_5': (360, 805),
}
print('\n=== Level 12 Steps ===')
print('ring_2 target (to r0):', round(angle_deg(p12['ring_2'], p12['ring_0']), 1))
print('ring_4 target (to r1):', round(angle_deg(p12['ring_4'], p12['ring_1']), 1))
print('ring_0 target (to r3):', round(angle_deg(p12['ring_0'], p12['ring_3']), 1))
print('ring_1 target (to r3):', round(angle_deg(p12['ring_1'], p12['ring_3']), 1))
print('ring_3 target (to r5):', round(angle_deg(p12['ring_3'], p12['ring_5']), 1))
