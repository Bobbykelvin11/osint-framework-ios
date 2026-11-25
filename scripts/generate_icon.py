#!/usr/bin/env python3
import math
import os
from PIL import Image, ImageDraw

SIZE = 1024
OUT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "OSINTFramework",
    "Assets.xcassets",
    "AppIcon.appiconset",
    "AppIcon-1024.png",
)

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)

# High-res canvas for smooth anti-aliasing (2x)
SCALE = 2
W = SIZE * SCALE
H = SIZE * SCALE

img = Image.new("RGB", (W, H), (18, 22, 31))
draw = ImageDraw.Draw(img)

# Subtle radial gradient background
cx, cy = W // 2, H // 2
for r in range(W, 0, -16):
    t = 1.0 - (r / W)
    col = (
        int(18 + 16 * t),
        int(22 + 28 * t),
        int(31 + 42 * t),
    )
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)

# Horizontal OSINT Framework style branching tree (left root -> 3 branches -> 6 leaves)
root = (360, cy)
mid_nodes = [
    (940, cy - 480),
    (940, cy),
    (940, cy + 480),
]
leaf_nodes = [
    (1620, cy - 660),
    (1620, cy - 300),
    (1620, cy - 110),
    (1620, cy + 110),
    (1620, cy + 300),
    (1620, cy + 660),
]

def draw_cubic_bezier(d, p0, p1, p2, p3, color, width, steps=80):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        mt = 1.0 - t
        x = (mt**3)*p0[0] + 3*(mt**2)*t*p1[0] + 3*mt*(t**2)*p2[0] + (t**3)*p3[0]
        y = (mt**3)*p0[1] + 3*(mt**2)*t*p1[1] + 3*mt*(t**2)*p2[1] + (t**3)*p3[1]
        pts.append((x, y))
    d.line(pts, fill=color, width=width, joint="curve")

def link(p0, p3, color, width=18):
    mid_x = (p0[0] + p3[0]) / 2.0
    p1 = (mid_x, p0[1])
    p2 = (mid_x, p3[1])
    draw_cubic_bezier(draw, p0, p1, p2, p3, color, width)

# Draw links
link_color = (74, 158, 218)      # #4A9EDA
link_soft = (110, 178, 228)

for m in mid_nodes:
    link(root, m, link_color, width=22)

for idx, l in enumerate(leaf_nodes):
    parent = mid_nodes[idx // 2]
    link(parent, l, link_soft, width=16)

def draw_node(center, radius, fill_col, stroke_col, stroke_w=18):
    x, y = center
    r = radius + stroke_w
    draw.ellipse([x - r, y - r, x + r, y + r], fill=stroke_col)
    draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=fill_col)

# Draw nodes (white fill / stroke to match OSINT tree aesthetic)
draw_node(root, 96, (255, 255, 255), (74, 158, 218), stroke_w=24)
for m in mid_nodes:
    draw_node(m, 64, (28, 36, 52), (255, 255, 255), stroke_w=20)
for i, l in enumerate(leaf_nodes):
    fill = (74, 158, 218) if i % 2 == 0 else (255, 255, 255)
    draw_node(l, 44, fill, (255, 255, 255), stroke_w=14)

final = img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
final.save(OUT_PATH, "PNG")
print(f"Generated icon at {OUT_PATH} ({SIZE}x{SIZE})")
