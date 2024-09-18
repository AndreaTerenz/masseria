@tool
class_name IdleStep
extends BTAction

var here : Vector2 :
	get:
		return agent.global_position
	set(h):
		agent.global_position = h
var path : Path2D
var offset := 0.0

# Called to initialize the task.
func _setup() -> void:
	path = agent.path

# Called when the task is entered.
func _enter() -> void:
	# Assumes agent is already on the idle path
	offset = path.curve.get_closest_offset(here)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	offset += delta * agent.mov_speed

	here = path.to_global(path.curve.sample_baked(offset))
	
	if offset >= path.curve.get_baked_length():
		offset = 0.
	
	return SUCCESS
