extends Particles2D

export (float) var lifeTime = 1.0

onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_OnTimer")
	timer.start(lifeTime)
	emitting = true

func _OnTimer():
	queue_free()
