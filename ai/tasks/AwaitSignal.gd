@tool
class_name AwaitSignal
extends BTAction

@export var signal_source : BBNode
@export var signal_name : BBStringName

var waiting := false
var signal_valid := true
var node : Node = null

"""
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Move to closest of group %s" % [_group]
"""

func saved_or_variable(param: BBParam):
	if param == null:
		return "???"
		
	if param.value_source == BBParam.SAVED_VALUE:
		return param.saved_value
	
	return "$" + param.variable if Engine.is_editor_hint() else param.get_value(scene_root, blackboard)

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	var s = saved_or_variable(signal_source)
	var n = saved_or_variable(signal_name)
	
	return "Await signal %s from %s" % [n, str(s)]

# Called when the task is entered.
func _enter() -> void:
	node = saved_or_variable(signal_source)
	
	var sig_name : StringName = saved_or_variable(signal_name)
	
	if not node.has_signal(sig_name):
		printerr("Node %s has no signal %s" % [node, signal_name])
		signal_valid = false
		return
		
	#HACK: IF THE SIGNAL'S ARITY IS NOT THE SAME AS THE CALLABLE'S, THE CONNECTION
	#WILL SILENTLY FAIL - DUMB DUMB GODOT STUFF
	#If they add variadic functions into 4.4 this is fixed
	node.connect(sig_name, _on_signal_received)
	
	waiting = true
	
func _on_signal_received():
	waiting = false
	
	var sig_name : StringName = saved_or_variable(signal_name)
	
	node.disconnect(sig_name, _on_signal_received)
	
func _tick(delta: float) -> Status:
	if not signal_valid:
		return FAILURE
	
	return RUNNING if waiting else SUCCESS
