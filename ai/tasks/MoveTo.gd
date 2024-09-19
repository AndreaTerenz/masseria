@tool
class_name MoveTo
extends BTAction

@export var target_group : StringName

var here : Vector2 :
	get:
		return agent.global_position
	set(h):
		agent.global_position = h
var group_valid: bool :
	get:
		if target_group.strip_edges() == "":
			return false
		if Engine.is_editor_hint():
			return true
			
		return agent.get_tree().has_group(target_group) if agent else false

var target : Vector2
var to_oven := false
var path : Path2D

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Move to closest of : %s" % [target_group] if group_valid else "Move to idle path"

# Called to initialize the task.
func _setup() -> void:
	path = agent.path


# Called when the task is entered.
func _enter() -> void:
	if group_valid:
		var tmp : Node2D = get_closest_of(target_group)
		target = tmp.global_position
		
		if target_group == &"Ovens":
			blackboard.set_var(&"current_oven", tmp)
	else:
		target = get_closest_path_point()


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var here : Vector2 = agent.global_position
	
	if here == target:
		return SUCCESS
	
	agent.global_position = here.move_toward(target, delta * agent.mov_speed)
	
	return RUNNING

func get_closest_of(group: StringName):
	if agent.action_target and group != "Fridges":
		return agent.action_target
	
	var here : Vector2 = agent.global_position
	var group_nodes := agent.get_tree().get_nodes_in_group(group)
			
	var min_dist := INF
	var closest = null
	for target in group_nodes:
		var d : float = target.global_position.distance_to(here)
		
		if group in ["Tables", "Ovens"] and target.occupied:
			continue
		
		if d < min_dist:
			min_dist = d
			closest = target
			
	if group != "Fridges":
		agent.action_target = closest
		if group != "Exit":
			agent.action_target.occupied = true
	
	return closest

func get_closest_path_point():
	var curve_p := path.to_local(here)
		
	return path.curve.get_closest_point(curve_p)
	
	#return path.curve.get_closest_offset(curve_p)
