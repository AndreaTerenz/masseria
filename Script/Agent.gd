class_name Agent
extends Node2D

var agent_id : StringName = &"default"
var left_tween: Tween
var right_tween: Tween

func _ready() -> void:
	add_to_group(&"Agents")
	
	position.x = randf_range(100., 500.)
	position.y = randf_range(100., 500.)
	
	AgentManager.add_agent(self)
	
	left_tween = create_tween().set_loops()
	left_tween.tween_property($LeftHand, "rotation_degrees", -90, 0.5).from(0)
	left_tween.tween_property($LeftHand, "rotation_degrees", 0, 0.5).from(-90)
	
	right_tween = create_tween().set_loops()
	right_tween.tween_property($RightHand, "rotation_degrees", -90, 0.5).from(0)
	right_tween.tween_property($RightHand, "rotation_degrees", 0, 0.5).from(-90)
