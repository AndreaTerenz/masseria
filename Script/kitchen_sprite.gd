class_name KitchenSprite
extends Sprite2D

var occupied : bool :
	get:
		return user != null
var user : Agent = null:
	set(u):
		if user == u or not _can_user_change():
			pass #return
		
		user = u
		self.self_modulate = Color("ff8888") if occupied else Color.WHITE
		
		_on_user_changed()
		
		if u == null:
			pass

func _on_user_changed():
	pass

# HACK meant for ovens
func _can_user_change():
	return true
