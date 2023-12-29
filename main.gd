extends Node

@export var pipe_scene: PackedScene
var score


func _ready():
	pass

func _process(delta):
	pass

func game_over():
	$PipeTimer.stop()
	$BackgroundMusic.stop()
	$UI.show_game_over()

func new_game():
	score = 0
	$UI.update_score(score)
	$UI.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$BackgroundMusic.play()
	$PipeTimer.start()

func _on_pipe_timer_timeout():
	var pipe = pipe_scene.instantiate()
	var pipe_parts = pipe.get_children()
	var delta_y = randi() % 450
	var velocity = Vector2(-200, 0)
	for part in pipe_parts:
		if part.name != 'VisibleOnScreenNotifier2D':
			part.linear_velocity = velocity
			part.position.y -= delta_y
	add_child(pipe)

func _on_player_score_increased():
	score += 1
	$ScoreSound.play()
	$UI.update_score(score)
