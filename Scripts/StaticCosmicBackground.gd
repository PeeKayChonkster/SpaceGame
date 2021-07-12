extends Sprite

export(float) var rotationSpeed = 0.01

func _physics_process(delta):
	global_position = get_viewport().get_camera().global_position
