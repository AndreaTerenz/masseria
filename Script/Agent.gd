class_name Agent
extends Node2D

signal delivered

enum STATE {
	IDLE, #0
	FRIDGE, #1 -> starting point of action 0 and 1
	TABLE, #2
	OVEN, #3 -> starting point of action 2
	SERVING, #4 -> starting point of action 3
	BREAK
}

@export var mov_speed := 500.0
@export var path : Path2D

@onready var bt_player: BTPlayer = $BTPlayer

var agent_id : StringName = &"default"
var possible_actions = [true, true, false, false]
var kitchen = null
var break_location = null
var current_action = -1
var action_target = null

var state := STATE.IDLE :
	set(s):
		if s in [STATE.OVEN, STATE.SERVING] and action_target:
			action_target.occupied = false
		elif s in [STATE.IDLE, STATE.BREAK]:
			self.rotation_degrees = 0
			if current_action not in [-1, 3]:
				kitchen.add_job(current_action+1, action_target)
				action_target = null
			elif current_action == 3:
				emit_signal("delivered")
		if s == STATE.BREAK:
			current_action = -1
		state = s

func _ready() -> void:
	add_to_group(&"Agents")
	
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
	
	var action_bb_vars := [&"PASTAMAN",
		&"DECORATOR",
		&"COOK",
		&"WAITER"]
	
	possible_actions.shuffle()	
	for i in range(len(action_bb_vars)):
		bt_player.blackboard.set_var(action_bb_vars[i], possible_actions[i])
	
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
			if position == break_location:
				rotation_degrees += 1
		STATE.IDLE:
			var new_job = kitchen.request_job(possible_actions)
			if new_job[0] != -1:
				current_action = new_job[0]
				action_target = new_job[1]
				state = current_action + 1
				if state == STATE.TABLE:
					state = STATE.FRIDGE
	
func get_possible_actions():
	return [possible_actions.find(true), possible_actions.rfind(true)]
