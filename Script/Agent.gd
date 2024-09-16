class_name Agent
extends Node2D

var agent_id : StringName = &"default"
var possible_actions = [true, true, false, false]


func _ready() -> void:
	add_to_group(&"Agents")
	
	# position.x = randf_range(100., 500.)
	# position.y = randf_range(100., 500.)
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
	
	
func get_possible_actions():
	return [possible_actions.find(true), possible_actions.rfind(true)]

func _on_broadcast(id: StringName, data: Variant):
	pass
