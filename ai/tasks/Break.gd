@tool
class_name Break
extends BTAction

@export var time_limit := 10.0

var elapsed := 0.0
var target : Vector2

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Do lil break dance"

# Called when the task is entered.
func _enter() -> void:
	elapsed = 0.0

# Called when the task is exited.
func _exit() -> void:
	agent.rotation = 0.

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.rotation += delta * agent.break_dance_speed
	elapsed += delta
	
	return RUNNING if elapsed < time_limit else SUCCESS
