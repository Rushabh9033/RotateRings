extends Control
class_name LoopshiftVictoryModal

signal next_pressed
signal replay_pressed
signal levels_pressed

@onready var title_lbl: Label = $Panel/VBox/RibbonPanel/Title
@onready var score_lbl: Label = $Panel/VBox/ScoreLbl
@onready var subtitle_lbl: Label = $Panel/VBox/Subtitle
@onready var next_btn: Button = $Panel/VBox/NextBtn

func _ready() -> void:
	next_btn.pressed.connect(func(): next_pressed.emit(); hide())

func show_victory(moves: int, _par_moves: int, is_perfect: bool, _best_moves: int, next_lvl_id: int = 2) -> void:
	if is_perfect:
		title_lbl.text = "Well Played!"
		subtitle_lbl.text = "Fantastic, you played this level perfectly!"
	else:
		title_lbl.text = "You Did It!"
		subtitle_lbl.text = "Keep pushing, you're getting even better!"
		
	var final_score := moves * 100 + 1500
	score_lbl.text = str(final_score)
	next_btn.text = "Level %d" % next_lvl_id
	
	scale = Vector2(0.85, 0.85)
	modulate.a = 0.0
	show()
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.28)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
