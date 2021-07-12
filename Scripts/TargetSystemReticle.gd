extends Node2D

onready var animationPlayer = $AnimationPlayer

signal ready_to_fire

func _ready():
	hide()
	set_as_toplevel(true)
	animationPlayer.connect("animation_finished", self, "_Aimed")

func Aim(speedMultiplier: float):
	show()
	animationPlayer.play("Aim", -1, speedMultiplier)

func _Aimed(_anim):
	if(_anim == "Aim"):
		animationPlayer.play("Aimed")
		emit_signal("ready_to_fire")

func StopAiming():
	hide()
	animationPlayer.stop()
