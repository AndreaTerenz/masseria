extends Node

signal new_agent(a: Agent)
signal agent_removed(a: Agent)
signal broadcast(id: StringName, data: Variant)
signal job_added(id: int, loc: Node, idx: int)
signal job_removed(id: int, loc: Node, idx: int)

var agent_scene : PackedScene = preload("res://Scenes/Agent.tscn")

var jobs : Array[Array] = []
var emergency = false
var patience := Timer.new()
var cooldown_timer := Timer.new()
var on_cooldown := false :
	set(c):
		on_cooldown = c
		if c:
			cooldown_timer.start()
		else:
			cooldown_timer.stop()
			
# Dummy node to contain Agent nodes
var agents := Node.new()
var count : int :
	get():
		return agents.get_child_count()

func _ready() -> void:
	# HACK: This fix is extremely ass. It works.
	add_child(cooldown_timer)
	cooldown_timer.wait_time = 0.2
	cooldown_timer.timeout.connect(func():
		on_cooldown = false
	)
	
	add_child(patience)
	patience.wait_time = 3
	patience.timeout.connect(func():
		emergency = true
	)
	
	add_child(agents)

func add_agent() -> Agent:
	var a : Agent = agent_scene.instantiate()
	
	a.agent_id = str(count)
	agents.add_child(a)
	
	print("Added agent %s" % a.agent_id)
	
	new_agent.emit(a)
	
	return a
	
func remove_agent(id := "") -> Agent:
	if count == 0:
		print("No agent in the current scene.")
		return null
		
	var agg_nodes = agents.get_children()
	var removed : Agent = null
	
	if id.strip_edges() == "":
		removed = agents.pick_random()
	else:
		var tmp := agg_nodes.filter(func (a: Agent): return a.agent_id == id)
		
		if len(tmp) == 0:
			print("No agent found with id %s" % id)
			return null
			
		removed = tmp[0]
	
	agents.remove_child(removed)
	
	agent_removed.emit(removed)
	print("Removed agent %s" % id)
	
	return removed

func send_broadcast(signal_id: StringName, signal_data = null):
	broadcast.emit(signal_id, signal_data)

func add_job(id: int, location=null):
	var j := [id, location]
	
	print("Added job of type %d at %s" % j)
	
	job_added.emit(id, location, len(jobs))
	jobs.append(j)
	
	patience.start()
	
func request_job(curriculum):
	if on_cooldown:
		return [-1, null]
	
	var idx := -1
	var id_to_group := {
			0: &"Tables",
			2: &"Ovens"
		}
	
	if emergency:
		emergency = false
		if any_in_group_free(id_to_group[0]):
			idx = 0
		else:
			patience.start()
	else:
		for i in len(jobs):
			var job := jobs[i]
			var id : int = job[0]
			
			if not curriculum[id]:
				continue
			
			if not (id in id_to_group.keys()) or any_in_group_free(id_to_group[id]):
				idx = i
				break
		
	if idx == -1:
		#print("No valid job found for curriculum: %s" % [curriculum])
		return [-1, null]
			
	var output := jobs[idx]
	
	jobs.remove_at(idx)
	job_removed.emit(output[0], output[1], idx)
	
	on_cooldown = true
	
	if len(jobs) > 0:
		patience.start()
	else:
		patience.stop()

	return output

		
func any_in_group_free(group: StringName) -> bool:
	return get_tree().get_nodes_in_group(group).any(func (n): return not n.occupied)
