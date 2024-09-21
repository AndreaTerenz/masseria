class_name KitchenSprite
extends Sprite2D

var occupied := false :
	set(b):
		occupied = b
		
		self.self_modulate = Color("ff8888") if occupied else Color.WHITE
		
		_on_occupied_changed()

func _on_occupied_changed():
	pass
