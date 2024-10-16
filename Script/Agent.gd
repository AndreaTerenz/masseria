class_name Agent
extends Node2D

signal delivered

enum STATE {
	IDLE, #0
	FRIDGE, #1 -> starting point of action 0 and 1
	TABLE, #2
	OVEN, #3 -> starting point of action 2
	SERVING, #4 -> starting point of action 3
	BREAK, #5
	HELP #6
}

enum ACTION {
	NULL = -1,
	DOUGH = 0,
	SAUCE = 1,
	OVEN = 2,
	SERVE = 3
}

@export var mov_speed := 400.0
@export var break_dance_speed := 2.0
@export var path : Path2D

@onready var bt_player: BTPlayer = $BTPlayer
@onready var carrying : Node2D = $Carrying

var agent_id : StringName = &"default"
var readable_id : String :
	get:
		if not agent_id.is_valid_int():
			return agent_id
			
		return Global.italian_names[int(agent_id) % Global.italian_names.size()]

var color: Color
var possible_jobs : Array[bool] = [true, true, false, false]
var kitchen : Node2D = null
#var break_location := Vector2.ZERO
var break_location = null
var idle_path_offset := 0.0
var action_target : Node2D = null
var current_action := ACTION.NULL
var patience := Timer.new()
var waiting = false

# RL stuff
var m := 0.0
var q := 0.0
var lr := 0.5
var rl_steps := 0

var state := STATE.IDLE :
	set(s):
		if s in [STATE.IDLE, STATE.BREAK]:
			self.rotation_degrees = 0
			if current_action == ACTION.OVEN:
				# Do nothing, the oven will add the job once the pizza is ready
				pass
			elif current_action == ACTION.SERVE:
				emit_signal("delivered")
			carrying.hide()
		elif s == STATE.HELP:
			waiting = true
				
		match s:
			STATE.OVEN:
				action_target.occupied = false
				carrying.play("pizza")
			STATE.SERVING:
				carrying.play("cooked_pizza")
			STATE.TABLE:
				if current_action == ACTION.DOUGH:
					carrying.play("dough")
				else:
					carrying.play("tomato")
			STATE.BREAK:
				current_action = ACTION.NULL
		state = s
		# print("Agent ", agent_id, " switched to ", s)

func _ready() -> void:
	add_to_group(&"Agents")
	
	possible_jobs.shuffle()
	color = Color.from_hsv(randf(), 0.75, 1)
	
	AgentManager.register_agent(self)
	AgentManager.broadcast.connect(func(id: StringName, data: Variant):
		print("Agent %s received broadcast '%s'" % [agent_id, id])
		_on_broadcast(id, data)
	)

	oscillate_sprite($LeftHand)
	oscillate_sprite($RightHand)
	
	var action_bb_vars := [&"PASTAMAN", &"DECORATOR", &"COOK", &"WAITER"]
	
	for i in range(len(action_bb_vars)):
		bt_player.blackboard.set_var(action_bb_vars[i], possible_jobs[i])
	
	
	var to_bind := [&"state", &"current_action", &"action_target", &"waiting"]
	for v in to_bind:
		bt_player.blackboard.bind_var_to_property(v, self, v)
		
	state = STATE.IDLE
	idle_path_offset = 0.0
	global_position = path.to_global(path.curve.sample_baked(idle_path_offset))
	
	$Face.modulate = color
	
	add_child(patience)
	patience.timeout.connect(func():
		current_action += 1
		
		state = current_action + 1
		if state == STATE.TABLE:
			state = STATE.FRIDGE
	)
	patience.wait_time = 3
	patience.one_shot = true

	
func _on_broadcast(id, _val):
	if id == &"PISELLARE" and possible_jobs[0] and state == STATE.IDLE:
		state = STATE.FRIDGE
		current_action = ACTION.DOUGH
		
# Probably useless
func _on_direct_signal(_id, _val):
	if state == STATE.BREAK:
		state = STATE.IDLE
		current_action = ACTION.NULL

func idle_step(delta: float):
	idle_path_offset += delta * mov_speed
	
	if idle_path_offset >= path.curve.get_baked_length():
		idle_path_offset = 0.
		
	global_position = path.to_global(path.curve.sample_baked(idle_path_offset))

func request_new_job():
	var new_job = kitchen.request_job(possible_jobs)
	if new_job[0] == ACTION.NULL:
		return
		
	current_action = new_job[0]
	action_target = new_job[1]
	
	state = current_action + 1
	if state == STATE.TABLE:
		state = STATE.FRIDGE
	
func get_possible_jobs():
	return [possible_jobs.find(true), possible_jobs.rfind(true)]
	
func calculate_table_action():
	if current_action == ACTION.DOUGH:
		var dough = action_target.get_dough()
		var action = []
		for dim in range(dough.size()):
			action.append(dough[dim] * m + q)
		var reward = action_target.evaluate_dough(action)

		var err_m = 0.0
		var err_q = 0.0
		for dim in range(dough.size()):
			err_m += reward[dim] * dough[dim]
			err_q += reward[dim]
		err_m /= dough.size()
		err_q /= dough.size()
		
		m -= -lr * err_m
		q -= -lr * err_q
		
		# print("M for Agent ", agent_id, ": ", m, ", Q: ", q)
		
		rl_steps += 1
		if rl_steps == 20 and lr > 0.1:
			lr /= 2
	
func oscillate_sprite(sprite):
	var r_tween := create_tween().set_loops()
	r_tween.tween_property(sprite, "rotation_degrees", -90, 0.5).from(0)
	r_tween.tween_property(sprite, "rotation_degrees", 0, 0.5).from(-90)

func _on_view_range_body_entered(body):
	if waiting:
		print("View results: ", body.get_class(), self.get_class(), body != self)
		if body.get_class() == self.get_class() and body != self:
			body.ask_for_help(current_action+1, action_target, self)
			print("Agent ", agent_id, " asked agent ", body.agent_id, " for help")
			
func ask_for_help(target_job, target, requester):
	if possible_jobs[target_job] and state == STATE.IDLE:
		requester.accept_request()
		
		current_action = target_job
		action_target = target

		state = current_action + 1
		if state == STATE.TABLE:
			state = STATE.FRIDGE

func accept_request():
	action_target = null
	waiting = false
	patience.stop()

func start_patience():
	patience.start()
