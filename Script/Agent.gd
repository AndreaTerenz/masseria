class_name Agent
extends Node2D

var agent_id : StringName = &"default"

func _ready() -> void:
	add_to_group(&"Agents")
	
	position.x = randf_range(100., 500.)
	position.y = randf_range(100., 500.)
	
	AgentManager.add_agent(self)
