class_name Agent
extends Node2D

var agent_id : StringName = &"default"
var possible_actions = [true, true, false, false]

@export var mov_speed := 500.0
@export var path : Path2D

@onready var bt_player: BTPlayer = $BTPlayer

var kitchen = null
var current_action = -1

enum STATE {
	IDLE, #0
	FRIDGE, #1 -> starting point of action 0 and 1
	TABLE, #2
	OVEN, #3 -> starting point of action 2
	SERVING, #4 -> starting point of action 3
	BREAK
}

var state := STATE.IDLE :
	set(s):
		print(s)
		if s in [STATE.IDLE, STATE.BREAK] and current_action not in [-1, 3]:
			kitchen.add_job(current_action+1)
		state = s

func _ready() -> void:
	add_to_group(&"Agents")
	
	# position.x = randf_range(100., 500.)
	# position.y = randf_range(100., 500.)
	possible_actions.shuffle()
	
	AgentManager.register_agent(self)
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
	
	
	bt_player.blackboard.set_var(&"PASTAMAN", possible_actions[0])
	bt_player.blackboard.set_var(&"DECORATOR", possible_actions[1])
	bt_player.blackboard.set_var(&"COOK", possible_actions[2])
	bt_player.blackboard.set_var(&"WAITER", possible_actions[3])
	
	bt_player.blackboard.bind_var_to_property(&"state", self, &"state")
	bt_player.blackboard.bind_var_to_property(&"current_action", self, &"current_action")
	
	state = STATE.IDLE
	
	
func _on_broadcast(id, val):
	if id == &"PISELLARE" and possible_actions[0] and state == STATE.IDLE:
		state = STATE.FRIDGE
		current_action = 0
		
# Probably useless
func _on_direct_signal(id, val):
	if state == STATE.BREAK:
		state = STATE.IDLE
		current_action = -1
	
func _process(delta):
	match state:
		STATE.BREAK:
			rotation_degrees += 1
		STATE.IDLE:
			var new_job = kitchen.request_job(possible_actions)
			if new_job[0] != -1:
				current_action = new_job[0]
				state = current_action + 1
				if state == STATE.TABLE:
					state = STATE.FRIDGE
	
func get_possible_actions():
	return [possible_actions.find(true), possible_actions.rfind(true)]
