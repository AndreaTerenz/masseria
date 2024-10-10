@tool
class_name MoveTo
extends BTAction

@export var target_group : BBStringName

var here : Vector2 :
	get:
		return agent.global_position
	set(h):
		agent.global_position = h
var _group : StringName :
	get:
		return saved_or_variable(target_group)

var target : Vector2
var to_oven := false

func saved_or_variable(param: BBParam):
	if param == null:
		return "???"
		
	if param.value_source == BBParam.SAVED_VALUE:
		return param.saved_value
	
	return "$" + (param.variable if Engine.is_editor_hint() else param.get_value(scene_root, blackboard))

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Move to closest of group %s" % [_group]


# Called when the task is entered.
func _enter() -> void:
	var tmp : Node2D = get_closest_of(_group)
	target = tmp.global_position


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var here : Vector2 = agent.global_position
	
	if here.is_equal_approx(target):
		return SUCCESS
	
	agent.global_position = here.move_toward(target, delta * agent.mov_speed)
	
	return RUNNING

func get_closest_of(group: StringName):
	if agent.action_target and group != &"Fridges":
		return agent.action_target
	
	var here : Vector2 = agent.global_position
	var group_nodes := agent.get_tree().get_nodes_in_group(group)
			
	var min_dist := INF
	var closest = null
	
	for target in group_nodes:
		var d : float = target.global_position.distance_to(here)
		
		if group in [&"Tables", &"Ovens"] and target.occupied:
			continue
		
		if d < min_dist:
			min_dist = d
			closest = target
	
	if group not in [&"Fridges"] and closest:
		agent.action_target = closest
		
		if group not in [&"Exit", &"Break"]:
			agent.action_target.occupied = true
	
	return closest
