extends Node

signal new_agent(a: Agent)
signal agent_removed(a: Agent)

const ID_ALPHABET := "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ID_LENGTH := 24

var agents : Array[Agent] = []

func add_agent(a: Agent):
	agents.append(a)
	new_agent.emit(a)
	
	a.agent_id = generate_agent_id()
	
	print(a.agent_id)
	
func remove_agent(id := -1):
	if len(agents) == 0:
		return
	
	if id < 0:
		id = randi_range(0, len(agents)-1)
	
	var removed : Agent = agents.pop_at(id)
	
	agent_removed.emit(removed)
	
	return removed

func generate_agent_id():
	var word: String
	var n_char = len(ID_ALPHABET)
	for i in range(ID_LENGTH):
		word += ID_ALPHABET[randi_range(0, n_char-1)]
		
		if (i+1) < ID_LENGTH and (i+1) % 8 == 0:
			word += "-"
	return word
