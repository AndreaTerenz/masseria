extends Node

signal new_agent(a: Agent)
signal agent_removed(a: Agent)

var agents_created = 0
enum {ACTION_DOUGH, ACTION_TOPPING, ACTION_COOK, ACTION_SERVE}

var agents : Array[Agent] = []

func add_agent(a: Agent):
	agents.append(a)
	new_agent.emit(a)
	
	a.agent_id = str(agents_created)
	agents_created += 1
	
	print("Added agent " + a.agent_id)
	print("Agent " + a.agent_id + " can do actions " + str(a.get_possible_actions()[0]) + 
			" and " + str(a.get_possible_actions()[1]))
	
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

# Deprecated
func generate_agent_id():
	const ID_ALPHABET := "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const ID_LENGTH := 24
	var word: String
	var n_char = len(ID_ALPHABET)
	for i in range(ID_LENGTH):
		word += ID_ALPHABET[randi_range(0, n_char-1)]
		
		if (i+1) < ID_LENGTH and (i+1) % 8 == 0:
			word += "-"
	return word
