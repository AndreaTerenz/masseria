extends Node

func _ready() -> void:
	seed(69420)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("db_quit"):
		get_tree().quit()
