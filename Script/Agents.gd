extends Node

signal new_agent(a: Agent)
signal agent_removed(a: Agent)
signal broadcast(id: StringName, data: Variant)

var agents_created = 0
var agents : Array[Agent] = []

func register_agent(a: Agent):
	agents.append(a)
	
	a.agent_id = str(agents_created)
	agents_created += 1
	
	print("Added agent %s" % a.agent_id)
	
	new_agent.emit(a)
	
func remove_agent(id := "") -> Agent:
	if len(agents) == 0:
		print("No agent in the current scene.")
		return null
	
	var removed : Agent = null
	
	if id.strip_edges() == "":
		removed = agents.pick_random()
	else:
		var tmp := agents.filter(func (a: Agent): return a.agent_id == id)
		
		if len(tmp) == 0:
			print("No agent found with id %s" % id)
			return null
			
		removed = tmp[0]
	
	agents.erase(removed)
	
	agent_removed.emit(removed)
	print("Removed agent %s" % id)
	
	return removed

func send_broadcast(signal_id: StringName, signal_data = null):
	broadcast.emit(signal_id, signal_data)
