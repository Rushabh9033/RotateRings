extends Control
class_name LoopshiftVictoryModal

const LevelDatabaseScript = preload("res://data/level_database.gd")
const UiTheme = preload("res://app/ui_theme.gd")

signal next_pressed
signal replay_pressed
signal levels_pressed

@onready var title_lbl: Label = $Panel/VBox/Title
@onready var score_lbl: Label = $Panel/VBox/ScoreLbl
@onready var subtitle_lbl: Label = $Panel/VBox/Subtitle
@onready var next_btn: Button = $Panel/VBox/NextBtn
@onready var replay_btn: Button = $Panel/VBox/ReplayBtn
@onready var levels_btn: Button = $Panel/VBox/LevelsBtn

func _ready() -> void:
	var dimmer := get_node_or_null("Dimmer") as ColorRect
	if dimmer:
		dimmer.color = UiTheme.DIMMER
	var panel := get_node_or_null("Panel") as Panel
	if panel:
		panel.add_theme_stylebox_override("panel", UiTheme.panel())
	UiTheme.paint_label(title_lbl, UiTheme.FONT_TITLE)
	UiTheme.paint_label(score_lbl, UiTheme.FONT_HEAD)
	UiTheme.paint_label(subtitle_lbl, 16, true)
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
		title_lbl.text = "Perfect"
		title_lbl.add_theme_color_override("font_color", UiTheme.PERFECT_DARK)
		subtitle_lbl.text = "You cleared this level within par."
	else:
		title_lbl.text = "Rings free"
		title_lbl.add_theme_color_override("font_color", UiTheme.ACCENT)
		subtitle_lbl.text = "Every connector let go."
		
	score_lbl.text = "Moves: %d / Par: %d" % [moves, _par_moves]
	
	if LevelDatabaseScript.is_level_playable(next_lvl_id):
		next_btn.text = "Level %d" % next_lvl_id
	else:
		if next_lvl_id != 0:
			push_warning("VictoryModal refused non-playable next level %d." % next_lvl_id)
		next_btn.text = "Chapter complete"
		
	var panel := get_node_or_null("Panel") as Control
	modulate.a = 0.0
	show()
	if panel:
		panel.pivot_offset = panel.size * 0.5
		panel.scale = Vector2(0.9, 0.9)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.22)
	if panel:
		tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.28)
