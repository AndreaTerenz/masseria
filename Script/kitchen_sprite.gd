extends Sprite2D

class_name KitchenSprite

var occupied := false :
	set(b):
		if b:
			self.modulate = "ff8888"
		else:
			self.modulate = "ffffff"
		occupied = b
