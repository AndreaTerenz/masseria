extends Node

signal new_agent(a: Agent)
signal agent_removed(a: Agent)
signal broadcast(id: StringName, data: Variant)

enum {ACTION_DOUGH, ACTION_TOPPING, ACTION_COOK, ACTION_SERVE}

var agents_created = 0
var agents : Array[Agent] = []
var data : Dictionary[StringName, Variant] = {}


func register_agent(a: Agent):
	agents.append(a)
	new_agent.emit(a)
	
	a.agent_id = str(agents_created)
	agents_created += 1
	
	print("Added agent %s" % a.agent_id)
	# print("Agent %s can do actions %s and %s" % 
	# 	[a.agent_id, a.get_possible_jobs()[0], a.get_possible_jobs()[1]])
	
func remove_agent(id := str(-1)):
	if len(agents) == 0:
		print("No agent in the current scene.")
		return
	
	var idx
	if int(id) < 0:
		idx = randi_range(0, len(agents)-1)
		id = agents[idx].agent_id
	else:
		idx = min(id, len(agents)-1)
		while idx >= 0:
			if agents[idx].agent_id == str(id):
				break
			idx -= 1
		
	if idx < 0:
		print("No agent found.")
		return
	
	var removed : Agent = agents.pop_at(idx)
	
	agent_removed.emit(removed)
	print("Removed agent " + str(id))
	
	return removed

func send_broadcast(signal_id: StringName, signal_data = null):
	broadcast.emit(signal_id, signal_data)
	
func set_global(key: StringName, value: Variant):
	data[key] = value
	
func get_global(key: StringName, default = null):
	return data.get(key, default)

# Deprecated
func generate_agent_id():
	const ID_ALPHABET := "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const ID_LENGTH := 24
	var word := ""
	var n_char = len(ID_ALPHABET)
	for i in range(ID_LENGTH):
		word += ID_ALPHABET[randi_range(0, n_char-1)]
		
		if (i+1) < ID_LENGTH and (i+1) % 8 == 0:
			word += "-"
	return word
