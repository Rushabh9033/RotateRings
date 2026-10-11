"""
render_l2_png.py — render the SVG to PNG for visual confirmation.
Requires: pip install cairosvg  (or use any SVG-to-PNG tool)
"""
import os
import sys

OUT_DIR = "tools/analyzer_outputs"

def main():
    level_id = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    svg_path = os.path.join(OUT_DIR, f"level_{level_id}_rendered.svg")
    png_path = os.path.join(OUT_DIR, f"level_{level_id}_rendered.png")
    try:
        import cairosvg
    except ImportError:
        print("cairosvg not installed; skipping PNG render.")
        print("Install with: pip install cairosvg")
        return
    if not os.path.exists(svg_path):
        print(f"SVG not found: {svg_path}; run render_l2_svg.py first.")
        return
    cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=720)
    print(f"PNG: {png_path}  ({os.path.getsize(png_path)} bytes)")


if __name__ == "__main__":
    main()