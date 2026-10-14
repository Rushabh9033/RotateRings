extends Control
class_name LoopshiftVictoryModal

const LevelDatabaseScript = preload("res://data/level_database.gd")
const UiTheme = preload("res://app/ui_theme.gd")
const UiIcons = preload("res://app/ui_icons.gd")

signal next_pressed
signal replay_pressed
signal levels_pressed

@onready var title_lbl: Label = $Panel/VBox/Title
@onready var score_lbl: Label = $Panel/VBox/ScorePill/ScoreLbl
@onready var score_pill: PanelContainer = $Panel/VBox/ScorePill
@onready var subtitle_lbl: Label = $Panel/VBox/Subtitle
@onready var star1: TextureRect = $Panel/VBox/StarsRow/Star1
@onready var star2: TextureRect = $Panel/VBox/StarsRow/Star2
@onready var star3: TextureRect = $Panel/VBox/StarsRow/Star3
@onready var next_btn: Button = $Panel/VBox/NextBtn
@onready var replay_btn: Button = $Panel/VBox/BtnRow/ReplayBtn
@onready var levels_btn: Button = $Panel/VBox/BtnRow/LevelsBtn

var _star_gold: Texture2D
var _star_empty: Texture2D

func _ready() -> void:
	_star_gold = UiIcons.make("star", UiTheme.PERFECT)
	_star_empty = UiIcons.make("star_empty", Color("D8C3AE"))

	var dimmer := get_node_or_null("Dimmer") as ColorRect
	if dimmer:
		dimmer.color = UiTheme.DIMMER
	var panel := get_node_or_null("Panel") as Panel
	if panel:
		panel.add_theme_stylebox_override("panel", UiTheme.panel())

	if score_pill:
		score_pill.add_theme_stylebox_override("panel", UiTheme.warm_pill())

	UiTheme.paint_label(title_lbl, UiTheme.FONT_TITLE)
	UiTheme.paint_label(score_lbl, UiTheme.FONT_BODY)
	UiTheme.paint_label(subtitle_lbl, 15, true)

	replay_btn.text = "Replay"
	levels_btn.text = "Level map"
	UiTheme.paint_button(next_btn, "primary", UiTheme.FONT_HEAD)
	UiTheme.paint_button(replay_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.paint_button(levels_btn, "secondary", UiTheme.FONT_BODY)

	UiTheme.apply_font(self)

	next_btn.pressed.connect(func(): next_pressed.emit(); hide())
	replay_btn.pressed.connect(func(): replay_pressed.emit(); hide())
	levels_btn.pressed.connect(func(): levels_pressed.emit(); hide())

func show_victory(moves: int, _par_moves: int, is_perfect: bool, _best_moves: int, next_lvl_id: int = 2) -> void:
	if is_perfect:
		title_lbl.text = "PERFECT!"
		title_lbl.add_theme_color_override("font_color", UiTheme.PERFECT_DARK)
		subtitle_lbl.text = "Masterful! Cleared within par moves."
	else:
		title_lbl.text = "LEVEL COMPLETE"
		title_lbl.add_theme_color_override("font_color", UiTheme.ACCENT)
		subtitle_lbl.text = "All rings and connectors free!"

	score_lbl.text = "Moves: %d   •   Par: %d" % [moves, _par_moves]

	if LevelDatabaseScript.is_level_playable(next_lvl_id):
		next_btn.text = "NEXT LEVEL  ▶"
	else:
		if next_lvl_id != 0:
			push_warning("VictoryModal refused non-playable next level %d." % next_lvl_id)
		next_btn.text = "ALL LEVELS CLEARED!"

	# Calculate stars (1, 2, or 3)
	var star_count := 1
	if is_perfect:
		star_count = 3
	elif _par_moves <= 0 or moves <= int(_par_moves * 1.4):
		star_count = 2

	var stars := [star1, star2, star3]
	for s in stars:
		s.texture = _star_empty
		s.scale = Vector2.ZERO
		s.pivot_offset = s.custom_minimum_size * 0.5

	var panel := get_node_or_null("Panel") as Control
	modulate.a = 0.0
	show()

	if panel:
		panel.pivot_offset = panel.size * 0.5
		panel.scale = Vector2(0.9, 0.9)

	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	if panel:
		tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.28)

	# Sequential bouncy star entrance
	for i in 3:
		var st: TextureRect = stars[i]
		var earned := (i < star_count)
		st.texture = _star_gold if earned else _star_empty
		st.scale = Vector2.ZERO
		var star_delay := 0.08 + float(i) * 0.14
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(st, "scale", Vector2.ONE, 0.3).set_delay(star_delay)
