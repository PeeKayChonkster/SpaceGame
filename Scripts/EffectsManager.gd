extends CanvasLayer


onready var flashPanel = $FlashPanel
onready var tween = $Tween

var maxFlashAlpha = 0.8

func _ready():
	Initialize()

func FlashScreen(time: float = 0.2, color: Color = Color.white):
	flashPanel.show()
	flashPanel.self_modulate = color
	flashPanel.self_modulate.a = 0.0
	tween.interpolate_property(flashPanel, "self_modulate:a", 0.0, maxFlashAlpha, time / 2.0)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(flashPanel, "self_modulate:a", maxFlashAlpha, 0.0, time / 2.0)
	tween.start()
	yield(tween, "tween_completed")
	flashPanel.hide()

func ShakeCamera(time: float = 0.5, amplitude: float = 20.0):
	var camera = GameController.player.camera
	while(time > 0):
		camera.global_position = lerp(camera.global_position, camera.global_position + Tools.RandomVec(amplitude), 0.2)
		time -= get_process_delta_time()
		yield(get_tree(), "idle_frame")

func Initialize():
	flashPanel.hide()
