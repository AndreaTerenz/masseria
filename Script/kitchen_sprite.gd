class_name KitchenSprite
extends Sprite2D

var occupied := false :
	set(b):
		if not _can_occupied_change():
			return
			
		occupied = b
		
		self.self_modulate = Color("ff8888") if occupied else Color.WHITE
		
		_on_occupied_changed()

func _on_occupied_changed():
	pass

# HACK meant for ovens
func _can_occupied_change():
	return true
