@tool
class_name GoToIdlePath
extends BTAction

@export var target_group : StringName

var here : Vector2 :
	get:
		return agent.global_position
	set(h):
		agent.global_position = h

var target : Vector2
var path : Path2D

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Return to idle path"

# Called to initialize the task.
func _setup() -> void:
	path = agent.path


# Called when the task is entered.
func _enter() -> void:
	target = get_closest_path_point()

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var here : Vector2 = agent.global_position
	
	if here.is_equal_approx(target):
		agent.idle_path_offset = path.curve.get_closest_offset(path.to_local(here))
		return SUCCESS
	
	agent.global_position = here.move_toward(target, delta * agent.mov_speed)
	
	return RUNNING

func get_closest_path_point():
	return path.to_global(path.curve.get_closest_point(path.to_local(here)))
