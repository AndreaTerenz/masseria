class_name Agent
extends Node2D

signal delivered
signal state_changed(s)
signal action_changed(a)

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
	SERVE = 3,
}

@export var base_speed := 400.0
@export var break_dance_speed := 2.0
@export var path : Path2D

@onready var bt_player: BTPlayer = $BTPlayer
@onready var carrying : Node2D = $Carrying
@onready var left_hand = $LeftHand
@onready var right_hand = $RightHand
@onready var face = $Face
@onready var highlight = $Highlight

var readable_id : String :
	get:
		if not agent_id.is_valid_int():
			return agent_id
			
		return Globals.italian_names[int(agent_id) % Globals.italian_names.size()]
var mov_speed : float :
	get:
		return base_speed * Globals.GAME_SPEED
var current_action := ACTION.NULL :
	set(a):
		if a == current_action:
			return
			
		current_action = a
		action_changed.emit(a)
var action_target : Node2D = null :
	set(new):
		_new_action_target(action_target, new)
		action_target = new
var state := STATE.IDLE :
	set(s):
		_new_state(state, s)
		state = s
var waiting = false :
	set(w):
		waiting = w
		if waiting:
			patience.start()
		else:
			patience.stop()
		
var agent_id : StringName = &"default"
var debug = false
var color: Color
var possible_jobs : Array[bool] = [true, true, false, false]
#var kitchen : Node2D = null
var idle_path_offset := 0.0
var patience := Timer.new()

# RL stuff
var m := 0.0
var q := 0.0
var lr := 0.5
var rl_steps := 0

func _ready() -> void:
	add_to_group(&"Agents")
	
	possible_jobs.shuffle()
	color = Color.from_hsv(randf(), 0.75, 1)
	
	Agents.broadcast.connect(func(id: StringName, data: Variant):
		print("Agent %s received broadcast '%s'" % [agent_id, id])
		_on_broadcast(id, data)
	)
	
	toggle_highlight(false)

	oscillate_sprite(left_hand)
	oscillate_sprite(right_hand)
	
	var action_bb_vars := [&"PASTAMAN", &"DECORATOR", &"COOK", &"WAITER"]
	
	for i in range(len(action_bb_vars)):
		bt_player.blackboard.set_var(action_bb_vars[i], possible_jobs[i])
	
	var to_bind := [&"state", &"current_action", &"action_target", &"waiting"]
	for v in to_bind:
		bt_player.blackboard.bind_var_to_property(v, self, v)
		
	state = STATE.IDLE
	
	idle_path_offset = 0.0
	path = get_tree().get_first_node_in_group(&"IdlePath")
	
	assert(path != null, "Failed to get idle path!")
	
	global_position = path.to_global(path.curve.sample_baked(idle_path_offset))
	
	face.modulate = color
	
	add_child(patience)
	patience.wait_time = 3
	patience.one_shot = true
	patience.timeout.connect(func():
		current_action += 1
		if current_action == ACTION.OVEN:
			action_target.occupied = false
		
		state = current_action + 1
		if state == STATE.TABLE:
			state = STATE.FRIDGE
			
		waiting = false
	)
	
func _on_broadcast(_id, _val):
	pass
		
# Probably useless
func _on_direct_signal(_id, _val):
	if state == STATE.BREAK:
		state = STATE.IDLE
		current_action = ACTION.NULL
		
func _process(delta: float) -> void:
	bt_player.update(delta * Globals.GAME_SPEED)

func idle_step(delta: float):
	idle_path_offset += delta * mov_speed 
	
	if idle_path_offset >= path.curve.get_baked_length():
		idle_path_offset = 0.
		
	global_position = path.to_global(path.curve.sample_baked(idle_path_offset))

func request_new_job():
	#var new_job = kitchen.request_job(possible_jobs)
	var new_job = Agents.request_job(possible_jobs)
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
	if current_action != ACTION.DOUGH:
		return
		
	assert(action_target != null)
		
	var dough = action_target.get_dough()
	var action = []
	for dim in range(len(dough)):
		action.append(dough[dim] * m + q)
	var reward = action_target.evaluate_dough(action)

	var err_m = 0.0
	var err_q = 0.0
	for dim in range(len(dough)):
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
	if not waiting:
		return
	
	var can_help : bool = (body.get_class() == self.get_class() and body != self)
	
	#print("View results: %s - %s" % [body, can_help])
	
	if not can_help:
		return
		
	body.ask_for_help(current_action+1, action_target, self)
	#print("Agent %s asked agent %s for help" % [agent_id, body.agent_id])
			
func ask_for_help(target_job, target, requester):
	if not possible_jobs[target_job] or state != STATE.IDLE:
		return false
		
	requester.accept_request()
	
	current_action = target_job
	action_target = target

	state = current_action + 1
	if state == STATE.TABLE:
		state = STATE.FRIDGE
	
	return true

func accept_request():
	action_target = null
	waiting = false

func start_patience():
	waiting = true
	
func send_order_back():
	Agents.add_job(current_action, null)
	print("Added back job ", current_action)

static func readable_job(job_idx: int) -> String:
	return ["Impastatore", "Decoratore", "Pizzaiolo", "Cameriere"][job_idx]

static func readable_state(s: STATE) -> String:
	return STATE.keys()[s]

static func readable_action(a: ACTION) -> String:
	return ACTION.keys()[a + 1]
	
func _new_state(_old, new):
	if new in [STATE.IDLE, STATE.BREAK]:
		self.rotation_degrees = 0
		if current_action == ACTION.OVEN:
			# Do nothing, the oven will add the job once the pizza is ready
			pass
		elif current_action == ACTION.SERVE:
			emit_signal("delivered")
		carrying.hide()
			
	match new:
		STATE.OVEN:
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
		STATE.HELP:
			waiting = true
			
	state_changed.emit(new)

func _new_action_target(old, new):
	if new == null and old == null:
		return
	
	# I HAVE TO DO IT LIKE THIS BECAUSE GODOT IS VERY STUPID AND EVALUATES THE ASSERT MESSAGE
	# EVEN BEFORE CHECKING THE ASSERT CONDITION ITSELF
	if not (new == null or old == null):
		assert(false, "%s is trying to use %s but is already using %s" % [readable_id, new.name, old.name])
	
	if state not in [STATE.SERVING, STATE.BREAK] and debug:
		if new != null:
			print("%s, during action %s, occupied %s" % [readable_id, readable_action(current_action), new.name])
		elif old != null:
			print("%s, during action %s, released %s" % [readable_id, readable_action(current_action), old.name])
		
		if new != null:
			new.user = self

func toggle_highlight(on: bool):
	highlight.visible = on
