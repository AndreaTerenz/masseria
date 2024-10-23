class_name KitchenSprite
extends Sprite2D

var occupied: bool = false:
	set(b):
		self.self_modulate = Color("ff8888") if b else Color.WHITE
		occupied = b
		
var is_self_oven = false

var user : Agent = null:
	set(u):
		if not is_self_oven:
			if u == null:
				occupied = false
			else:
				occupied = true
		
		user = u		
		_on_user_changed()


func _on_user_changed():
	pass
