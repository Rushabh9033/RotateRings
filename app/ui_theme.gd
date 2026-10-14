extends RefCounted

# Soft 2.5D casual puzzle chrome. Cream surfaces, warm ink, tactile buttons.

const BG := Color("F4E7D4")
const BOARD := Color("F7EFE3")
const SURFACE := Color("FFF8F0")
const SURFACE_RAISED := Color("FFFDF8")
const LINE := Color("E4CDB4")
const TEXT := Color("4A3428")
const TEXT_MUTED := Color("8A6554")
const TEXT_DIM := Color("B08974")
const ACCENT := Color("FF6A45")
const ACCENT_DARK := Color("D24428")
const ACCENT_TEXT := Color("FFF8F3")
const VIOLET := Color("7C6AE8")
const VIOLET_DARK := Color("5340B8")
const TEAL := Color("3EC6B0")
const TEAL_DARK := Color("1C8F7C")
const TEAL_TEXT := Color("07332C")
const CLEARED := Color("3CBF86")
const CLEARED_DARK := Color("1E8A5C")
const PERFECT := Color("F0B429")
const PERFECT_DARK := Color("C48412")
const LOCKED := Color("D9CBBA")
const DANGER := Color("E25B6A")
const DIMMER := Color(0.28, 0.16, 0.1, 0.46)

const RADIUS := 26
const SPACE := 8

# Casual mobile hit palette
const WARM_PILL_BG := Color("FCE8D3")
const WARM_PILL_BORDER := Color("EBC6A6")
const WARM_INK := Color("543324")
const RUSH_RED := Color("DC2626")
const GOLD_BORDER := Color("F4CF9E")
const GOLD_BORDER_BEVEL := Color("E8B67D")
const CARD_SURFACE := Color("FFFDF9")
const BADGE_RED := Color("E62638")
const BADGE_BORDER := Color("BF1B2A")

const FONT_DISPLAY := 48
const FONT_TITLE := 34
const FONT_HEAD := 22
const FONT_BODY := 18
const FONT_CAPTION := 15

static var _font: Font
static var _icons := {}


static func rounded_font() -> Font:
	if _font == null:
		var sys := SystemFont.new()
		sys.font_names = PackedStringArray(["Segoe UI", "Trebuchet MS", "Verdana"])
		sys.font_weight = 700
		_font = sys
	return _font


static func apply_font(root: Node) -> void:
	var face := rounded_font()
	if root is Label:
		root.add_theme_font_override("font", face)
	elif root is Button:
		root.add_theme_font_override("font", face)
	elif root is CheckBox:
		root.add_theme_font_override("font", face)
	for child in root.get_children():
		apply_font(child)


static func mount_backdrop(host: Node, board: bool = false) -> void:
	var bg := host.get_node_or_null("Background") as CanvasItem
	if bg:
		bg.visible = false
	var existing := host.get_node_or_null("Backdrop")
	if existing:
		existing.set("board_mode", board)
		return
	var backdrop: Control = preload("res://app/ui_backdrop.gd").new()
	backdrop.name = "Backdrop"
	backdrop.set("board_mode", board)
	host.add_child(backdrop)
	host.move_child(backdrop, 0)


static func present_modal(panel: Control) -> void:
	if panel == null:
		return
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.9, 0.9)
	var tween := panel.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.28)


static func panel() -> StyleBoxFlat:
	var box := _chunky(SURFACE, Color("E7D0B8"))
	box.shadow_color = Color(0.45, 0.28, 0.16, 0.18)
	box.shadow_size = 28
	box.shadow_offset = Vector2(0, 14)
	box.content_margin_left = 28.0
	box.content_margin_right = 28.0
	box.content_margin_top = 26.0
	box.content_margin_bottom = 26.0
	return box


static func pill() -> StyleBoxFlat:
	return warm_pill()


static func warm_pill() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = WARM_PILL_BG
	box.border_color = WARM_PILL_BORDER
	box.set_border_width_all(2)
	box.border_width_bottom = 3
	box.set_corner_radius_all(24)
	box.content_margin_left = 28.0
	box.content_margin_right = 28.0
	box.content_margin_top = 8.0
	box.content_margin_bottom = 8.0
	box.shadow_color = Color(0.42, 0.24, 0.12, 0.10)
	box.shadow_size = 6
	box.shadow_offset = Vector2(0, 3)
	return box


static func squircle_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = CARD_SURFACE
	normal.border_color = Color("EAD8C4")
	normal.set_border_width_all(2)
	normal.border_width_bottom = 5
	normal.set_corner_radius_all(18)
	normal.shadow_color = Color(0.38, 0.22, 0.12, 0.14)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 3)

	var hover := normal.duplicate()
	hover.bg_color = Color("FFFFFF")

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color("F5EDE4")
	pressed.border_color = Color("D6C2AC")
	pressed.set_border_width_all(2)
	pressed.border_width_bottom = 2
	pressed.set_corner_radius_all(18)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", WARM_INK)
	btn.add_theme_color_override("font_hover_color", WARM_INK)
	btn.add_theme_color_override("font_pressed_color", WARM_INK)
	btn.add_theme_font_override("font", rounded_font())

	if btn.text == "⚙" or btn.text == "settings":
		btn.text = ""
		btn.icon = preload("res://app/ui_icons.gd").make("settings", WARM_INK)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
	elif btn.text == "‹" or btn.text == "back":
		btn.text = ""
		btn.icon = preload("res://app/ui_icons.gd").make("back", WARM_INK)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true

	_bind_press(btn)


static func powerup_card() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = CARD_SURFACE
	box.border_color = GOLD_BORDER
	box.set_border_width_all(3)
	box.border_width_bottom = 7
	box.set_corner_radius_all(24)
	box.shadow_color = Color(0.42, 0.26, 0.14, 0.16)
	box.shadow_size = 10
	box.shadow_offset = Vector2(0, 6)
	return box


static func red_badge() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = BADGE_RED
	box.border_color = BADGE_BORDER
	box.border_width_bottom = 2
	box.set_corner_radius_all(14)
	box.shadow_color = Color(0.5, 0.1, 0.1, 0.28)
	box.shadow_size = 5
	box.shadow_offset = Vector2(0, 2)
	return box


static func gray_badge() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("788290")
	box.border_color = Color("5A6270")
	box.border_width_bottom = 2
	box.set_corner_radius_all(14)
	box.shadow_color = Color(0.1, 0.1, 0.1, 0.24)
	box.shadow_size = 5
	box.shadow_offset = Vector2(0, 2)
	return box


static func draw_c_ring(ci: CanvasItem, center: Vector2, radius: float, thickness: float, color: Color, gap_center_ang: float, gap_width_ang: float = 1.1) -> void:
	var half_gap := gap_width_ang * 0.5
	var start := gap_center_ang + half_gap
	var end := gap_center_ang + TAU - half_gap
	var segs := 48
	# 1. Base shadow
	var shadow := Color(0.35, 0.2, 0.12, 0.18)
	ci.draw_arc(center + Vector2(0, 3.5), radius, start, end, segs, shadow, thickness + 2.0, true)
	# 2. Darker base bevel
	ci.draw_arc(center + Vector2(0, 1.8), radius, start, end, segs, color.darkened(0.24), thickness, true)
	# 3. Main porcelain body
	ci.draw_arc(center, radius, start, end, segs, color, thickness, true)
	# 4. Top highlight
	var hi := Color(1, 1, 1, 0.6)
	ci.draw_arc(center + Vector2(-1.0, -1.2), radius, start + 0.2, end - 0.2, segs, hi, thickness * 0.3, true)
	# 5. Rounded end caps
	for ang in [start, end]:
		var cap := center + Vector2.from_angle(ang) * radius
		ci.draw_circle(cap + Vector2(0, 1.5), thickness * 0.5, color.darkened(0.24))
		ci.draw_circle(cap, thickness * 0.5, color)
		ci.draw_circle(cap + Vector2(-0.6, -0.6), thickness * 0.22, Color(1, 1, 1, 0.65))


static var _toggle_checked: Texture2D
static var _toggle_unchecked: Texture2D

static func _make_toggle_texture(checked: bool) -> Texture2D:
	var img := Image.create(56, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var bg_color := CLEARED if checked else Color("D4BCA6")
	var r := 16.0
	for y in 32:
		for x in 56:
			var p := Vector2(x + 0.5, y + 0.5)
			var inside := false
			if p.x >= 16 and p.x <= 40:
				inside = true
			elif p.distance_to(Vector2(16, 16)) <= r or p.distance_to(Vector2(40, 16)) <= r:
				inside = true
			if inside:
				if y <= 1:
					img.set_pixel(x, y, bg_color.darkened(0.16))
				else:
					img.set_pixel(x, y, bg_color)
	var thumb_c := Vector2(39, 16) if checked else Vector2(17, 16)
	var thumb_r := 11.5
	var thumb_r2 := thumb_r * thumb_r
	for y in 32:
		for x in 56:
			var p := Vector2(x + 0.5, y + 0.5)
			var d2 := p.distance_squared_to(thumb_c)
			if d2 <= thumb_r2:
				if p.y > 16 + thumb_r - 2.5:
					img.set_pixel(x, y, Color("EBE3DA"))
				elif p.y < 16 - thumb_r + 3.0:
					img.set_pixel(x, y, Color("FFFFFF"))
				else:
					img.set_pixel(x, y, Color("FAF7F2"))
	return ImageTexture.create_from_image(img)

static func paint_button(btn: Button, kind: String, font_size: int = FONT_BODY) -> void:
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	var pressed: StyleBoxFlat
	var disabled: StyleBoxFlat
	var ink: Color
	var ink_disabled := Color("B7A394")
	if kind == "primary":
		normal = _chunky(ACCENT, ACCENT_DARK)
		hover = _chunky(ACCENT.lightened(0.06), ACCENT_DARK, false)
		pressed = _pressed(ACCENT_DARK, ACCENT_DARK)
		disabled = _chunky(Color("F0C2B6"), Color("E0B0A4"), false)
		ink = ACCENT_TEXT
	elif kind == "success":
		normal = _chunky(CLEARED, CLEARED_DARK)
		hover = _chunky(CLEARED.lightened(0.06), CLEARED_DARK, false)
		pressed = _pressed(CLEARED_DARK, CLEARED_DARK)
		disabled = _chunky(Color("C9E6D6"), Color("B7D4C4"), false)
		ink = ACCENT_TEXT
	elif kind == "gold":
		normal = _chunky(PERFECT, PERFECT_DARK)
		hover = _chunky(PERFECT.lightened(0.06), PERFECT_DARK, false)
		pressed = _pressed(PERFECT_DARK, PERFECT_DARK)
		disabled = _chunky(Color("EAD7A4"), Color("D8C490"), false)
		ink = TEXT
	elif kind == "danger":
		normal = _chunky(Color("FFF1F2"), Color("E7B7BE"))
		hover = _chunky(Color("FFE4E7"), DANGER, false)
		pressed = _pressed(Color("F8D5DA"), Color("D9909A"))
		disabled = _chunky(SURFACE, LINE, false)
		ink = Color("A33A48")
	else:
		normal = _chunky(SURFACE_RAISED, Color("E4CDB4"))
		hover = _chunky(Color("FFFFFF"), Color("D9BFA4"), false)
		pressed = _pressed(Color("F3E4D2"), Color("C9AE94"))
		disabled = _chunky(Color("F6EEE6"), Color("E6D8C8"), false)
		ink = TEXT
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", ink)
	btn.add_theme_color_override("font_hover_color", ink)
	btn.add_theme_color_override("font_pressed_color", ink)
	btn.add_theme_color_override("font_focus_color", ink)
	btn.add_theme_color_override("font_disabled_color", ink_disabled)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_font_override("font", rounded_font())
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	var icon_tex := _icon_for(btn.text, ink)
	if icon_tex != null:
		btn.icon = icon_tex
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_bind_press(btn)


static func paint_label(label: Label, size: int, muted: bool = false) -> void:
	label.add_theme_font_override("font", rounded_font())
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_MUTED if muted else TEXT)


static func paint_check(check: CheckBox) -> void:
	if _toggle_checked == null:
		_toggle_checked = _make_toggle_texture(true)
		_toggle_unchecked = _make_toggle_texture(false)
	check.add_theme_icon_override("checked", _toggle_checked)
	check.add_theme_icon_override("checked_disabled", _toggle_checked)
	check.add_theme_icon_override("unchecked", _toggle_unchecked)
	check.add_theme_icon_override("unchecked_disabled", _toggle_unchecked)
	check.add_theme_font_override("font", rounded_font())
	check.add_theme_font_size_override("font_size", FONT_BODY)
	check.add_theme_color_override("font_color", TEXT)
	check.add_theme_color_override("font_hover_color", ACCENT)
	check.add_theme_color_override("font_pressed_color", TEXT)
	check.add_theme_color_override("font_focus_color", TEXT)
	check.add_theme_constant_override("h_separation", 16)


static func _bind_press(btn: Button) -> void:
	if btn.has_meta("soft_press"):
		return
	btn.set_meta("soft_press", true)
	btn.resized.connect(func() -> void:
		btn.pivot_offset = btn.size * 0.5
	)
	btn.pivot_offset = btn.size * 0.5
	btn.button_down.connect(func() -> void:
		if btn.disabled:
			return
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(0.97, 0.94), 0.07)
	)
	btn.button_up.connect(func() -> void:
		var tween := btn.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2.ONE, 0.16)
	)


static func _chunky(fill: Color, edge: Color, shadow: bool = true) -> StyleBoxFlat:
	var box := _box(fill, edge, 0)
	box.border_width_bottom = 8
	box.border_color = edge
	box.content_margin_top = 16.0
	box.content_margin_bottom = 16.0
	if shadow:
		box.shadow_color = Color(0.42, 0.24, 0.12, 0.16)
		box.shadow_size = 10
		box.shadow_offset = Vector2(0, 5)
	return box


static func _pressed(fill: Color, edge: Color) -> StyleBoxFlat:
	var box := _chunky(fill, edge, false)
	box.border_width_bottom = 3
	box.content_margin_top = 18.0
	box.content_margin_bottom = 14.0
	return box


static func _box(bg: Color, border: Color, border_w: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_w)
	box.set_corner_radius_all(RADIUS)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box


static func _icon_for(label: String, ink: Color) -> Texture2D:
	var key := label.strip_edges().to_lower()
	var kind := ""
	if key == "back" or key == "‹":
		kind = "back"
	elif key == "play" or key.begins_with("play") or key.begins_with("level ") or key == "next level":
		kind = "play"
	elif key == "pause":
		kind = "pause"
	elif key == "hint":
		kind = "hint"
	elif key == "settings" or key == "⚙":
		kind = "settings"
	elif key == "level map" or key == "map":
		kind = "map"
	elif key == "replay" or key == "restart":
		kind = "replay"
	elif key == "main menu" or key == "home":
		kind = "home"
	elif key == "close" or key == "x":
		kind = "close"
	elif key == "star":
		kind = "star"
	elif key == "level editor" or key == "edit":
		kind = "settings"
	if kind == "":
		return null
	var cache_key := kind + ":" + ink.to_html(false)
	if _icons.has(cache_key):
		return _icons[cache_key]
	var tex := preload("res://app/ui_icons.gd").make(kind, ink)
	_icons[cache_key] = tex
	return tex
