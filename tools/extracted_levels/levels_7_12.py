"""
COMPLETE LEVEL DEFINITIONS - Progressive Extraction
Adding levels 7-12 and continuing through all 100
"""

COMPLETE_LEVELS = {
    1: {
        "title": "First Twist",
        "instruction": "Turn the open ring until its gap takes the cuff.",
        "def": "_one(88.0, C, 94.0, 60.0, 122.0)"
    },
    
    2: {
        "title": "Purple Hook",
        "instruction": "Three open rings in a hook. Free the blue tip first.",
        "def": """_open_root(66.0, 90.0, [
\t\t\t_k(-102.0, 60.0, 176.0, [
\t\t\t\t_k(-14.0, 56.0, 168.0),
\t\t\t]),
\t\t])"""
    },
    
    3: {
        "title": "Blue Fork",
        "instruction": "The blue ring holds two paths. Clear the side, then the tail.",
        "def": """_open_root(68.0, 270.0, [
\t\t\t_k(128.0, 60.0, 188.0, [
\t\t\t\t_k(96.0, 56.0, 168.0),
\t\t\t]),
\t\t\t_k(46.0, 58.0, 172.0),
\t\t])"""
    },
    
    4: {
        "title": "Red Branch",
        "instruction": "A red ring roots a branch of six. Start at the loose tips.",
        "def": """_open_root(68.0, 180.0, [
\t\t\t_k(-55.0, 60.0, 150.0, [
\t\t\t\t_k(75.0, 56.0, 150.0, [
\t\t\t\t\t_k(85.0, 56.0, 150.0),
\t\t\t\t]),
\t\t\t]),
\t\t\t_k(60.0, 60.0, 150.0, [
\t\t\t\t_k(-85.0, 56.0, 150.0),
\t\t\t]),
\t\t])"""
    },
    
    5: {
        "title": "Wheel of Six",
        "instruction": "A closed circle holds six rings. Three of those rings are held twice.",
        "def": """_closed(78.0, C, [
\t\t\t_k(-90.0, 56.0, 150.0),
\t\t\t_k(-30.0, 60.0, 158.0),
\t\t\t_k(30.0, 56.0, 150.0),
\t\t\t_k(90.0, 58.0, 154.0),
\t\t\t_k(150.0, 62.0, 162.0),
\t\t\t_k(210.0, 58.0, 154.0),
\t\t], false, [[0, 1], [2, 3], [4, 5]])"""
    },
    
    6: {
        "title": "Side Clasp",
        "instruction": "An oval clasps two rings. Clear either neighbor.",
        "def": """_closed(70.0, O, [
\t\t\t_k(-90.0, 58.0, 136.0),
\t\t\t_k(-30.0, 64.0, 144.0),
\t\t\t_k(30.0, 56.0, 136.0),
\t\t\t_k(90.0, 62.0, 140.0),
\t\t\t_k(150.0, 60.0, 138.0),
\t\t\t_k(210.0, 66.0, 146.0),
\t\t], false, [[0, 1], [1, 2], [2, 3], [4, 5]])"""
    },
    
    7: {
        "title": "Square Hook",
        "instruction": "A square trails a short hook. Start at the tip.",
        "def": """_closed(68.0, S, [
\t\t\t_k(-90.0 + 10.0, 56.0, 136.0),
\t\t\t_k(-30.0 + 10.0, 64.0, 144.0),
\t\t\t_k(30.0 + 10.0, 56.0, 136.0),
\t\t\t_k(90.0 + 10.0, 62.0, 140.0),
\t\t\t_k(150.0 + 10.0, 60.0, 138.0),
\t\t\t_k(210.0 + 10.0, 66.0, 146.0),
\t\t], false, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]])"""
    },
    
    8: {
        "title": "Uneven Fork",
        "instruction": "Three different rings on a triangle, none evenly spaced.",
        "def": """_closed(74.0, T, [
\t\t\t_k(-140.0 - 8.0, 56.0, 134.0),
\t\t\t_k(-60.0 - 8.0, 62.0, 142.0),
\t\t\t_k(20.0 - 8.0, 58.0, 136.0),
\t\t\t_k(100.0 - 8.0, 64.0, 144.0),
\t\t\t_k(160.0 - 8.0, 56.0, 134.0),
\t\t\t_k(230.0 - 8.0, 60.0, 138.0),
\t\t], false, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]])"""
    },
    
    9: {
        "title": "Offset Pair",
        "instruction": "A short ring on one side, a longer chain on the other.",
        "def": """_closed(56.0, C, [
\t\t\t_k(-90.0 + 14.0, 56.0, 132.0),
\t\t\t_k(-30.0 + 14.0, 58.0, 140.0),
\t\t\t_k(30.0 + 14.0, 56.0, 132.0),
\t\t\t_k(90.0 + 14.0, 60.0, 136.0),
\t\t\t_k(150.0 + 14.0, 58.0, 140.0),
\t\t\t_k(210.0 + 14.0, 56.0, 132.0),
\t\t], false, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]])"""
    },
    
    10: {
        "title": "Short Curl",
        "instruction": "An oval trails a short curl. Start at the tip.",
        "def": """_closed(56.0, O, [
\t\t\t_k(-90.0 - 12.0, 56.0, 132.0),
\t\t\t_k(-30.0 - 12.0, 58.0, 140.0),
\t\t\t_k(30.0 - 12.0, 56.0, 132.0),
\t\t\t_k(90.0 - 12.0, 60.0, 136.0),
\t\t\t_k(150.0 - 12.0, 58.0, 140.0),
\t\t\t_k(210.0 - 12.0, 56.0, 132.0, [
\t\t\t\t_k(300.0, 62.0, 148.0),
\t\t\t]),
\t\t], false, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]])"""
    },
    
    11: {
        "title": "Forked Tail",
        "instruction": "A triangle holds three rings, and one of those rings carries a tail.",
        "def": """_closed(68.0, T, [
\t\t\t_k(-115.0, 72.0, 140.0),
\t\t\t_k(-35.0, 56.0, 154.0),
\t\t\t_k(60.0, 64.0, 136.0, [
\t\t\t\t_k(145.0, 58.0, 160.0),
\t\t\t]),
\t\t])"""
    },
    
    12: {
        "title": "Two Clusters",
        "instruction": "One cluster sits above the square, a longer one below.",
        "def": """_closed(70.0, O, [
\t\t\t_k(-110.0, 60.0, 132.0, [
\t\t\t\t_k(-20.0, 56.0, 149.0),
\t\t\t]),
\t\t\t_k(70.0, 64.0, 132.0, [
\t\t\t\t_k(160.0, 58.0, 149.0, [
\t\t\t\t\t_k(250.0, 62.0, 136.0),
\t\t\t\t]),
\t\t\t]),
\t\t])"""
    },
}

# Continue with remaining levels...
# This will be expanded with all 100 levels
