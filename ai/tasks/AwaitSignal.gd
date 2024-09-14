@tool
class_name AwaitSignal
extends BTAction

@export var signal_source : BBNode
@export var signal_name : BBStringName

var waiting := false
var signal_valid := true
var node : Node = null

# Called when the task is entered.
func _enter() -> void:
	node = signal_source.get_value(scene_root, blackboard)
	
	var sig_name : StringName = signal_name.get_value(scene_root, blackboard)
	
	if not node.has_signal(sig_name):
		signal_valid = false
		return
		
	#HACK: IF THE SIGNAL'S ARITY IS NOT THE SAME AS THE CALLABLE'S, THE CONNECTION
	#WILL SILENTLY FAIL - DUMB DUMB GODOT STUFF
	#If they add variadic functions into 4.4 this is fixed
	node.connect(sig_name, func():
		waiting = false
	)
	
	waiting = true
	
func _tick(delta: float) -> Status:
	if not signal_valid:
		return FAILURE
	
	return RUNNING if waiting else SUCCESS
