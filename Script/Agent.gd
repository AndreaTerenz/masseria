class_name Agent
extends Node2D

@export var path : Path2D

var agent_id : StringName = &"default"
var possible_actions = [1, 1, 1, 1]  # TODO: Replace with [1, 1, 0, 0]
var current_action = -1
var idle_speed = 400

enum {IDLE, MOVING, CARRYING, WORKING, WAITING}
var intent = null
var state = IDLE
var path_offset := 0.0


func _ready() -> void:
	add_to_group(&"Agents")
	possible_actions.shuffle()
	
	AgentManager.add_agent(self)
	AgentManager.broadcast.connect(func(id: StringName, data: Variant):
		print("Agent %s received broadcast '%s'" % [agent_id, id])
		_on_broadcast(id, data)
	)

	var left_tween := create_tween().set_loops()
	left_tween.tween_property($LeftHand, "rotation_degrees", -90, 0.5).from(0)
	left_tween.tween_property($LeftHand, "rotation_degrees", 0, 0.5).from(-90)
	
	var right_tween := create_tween().set_loops()
	right_tween.tween_property($RightHand, "rotation_degrees", -90, 0.5).from(0)
	right_tween.tween_property($RightHand, "rotation_degrees", 0, 0.5).from(-90)
	
	var curve_p := path.to_local(global_position)
	global_position = path.curve.get_closest_point(curve_p)
	path_offset = path.curve.get_closest_offset(curve_p)
	
	
func get_possible_actions():
	return [possible_actions.find(1), possible_actions.rfind(1)]

func _on_broadcast(id: StringName, data: Variant):
	action_request(2)
	
func action_request(action_id: int):
	if possible_actions[action_id]:
		match action_id:
			0, 1: 
				intent = find_closest("Fridges")
				state = MOVING
			2:
				intent = find_closest("Ovens")
				state = CARRYING
			3:
				intent = find_closest("Exit")
				state = CARRYING
				
		current_action = action_id
		
func _process(delta):
	match state:
		IDLE: 
			path_offset += delta * idle_speed
			global_position = path.to_global(path.curve.sample_baked(path_offset))
			if path_offset >= path.curve.get_baked_length():
				path_offset = 0.
		MOVING:
			var speed = idle_speed
			if position.x != intent.x and position.y != intent.y:
				speed = speed / sqrt(2)
			position.x = move_toward(position.x, intent.x, delta * speed)
			position.y = move_toward(position.y, intent.y, delta * speed)
			
			if position == intent:
				if current_action == 3:
					intent = null
					state = IDLE
				else:
					intent = find_closest("Tables")
					state = CARRYING
		CARRYING:
			var speed = idle_speed
			if position.x != intent.x and position.y != intent.y:
				speed = speed / sqrt(2)
			position.x = move_toward(position.x, intent.x, delta * speed)
			position.y = move_toward(position.y, intent.y, delta * speed)
			
			if position == intent:
				intent = null
				state = WORKING
				$Progress.show()
		WORKING:
			if $Progress.value == 100:
				$Progress.hide()
				
				if current_action == 3:
					var curve_p := path.to_local(global_position)
					intent = path.curve.get_closest_point(curve_p)
					path_offset = path.curve.get_closest_offset(curve_p)
					state = MOVING
				else:
					state = WAITING
					var spin_tween := create_tween().set_loops()
					spin_tween.tween_property(self, "rotation_degrees", 360, 4).from(0)
			else:	
				$Progress.set_value_no_signal($Progress.value + 0.5)
		
			
				
func find_closest(group: String):
	var min_dist := INF
	var closest = null
	for el in get_tree().get_nodes_in_group(group):
		var d : float = el.global_position.distance_to(global_position)
		
		if d < min_dist:
			min_dist = d
			closest = el
			
	return closest.global_position
