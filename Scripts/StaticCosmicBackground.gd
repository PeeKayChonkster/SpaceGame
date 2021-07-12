extends Sprite

export(float) var rotationSpeed = 0.01

func _process(delta):
	rotate(rotationSpeed * 0.01)
