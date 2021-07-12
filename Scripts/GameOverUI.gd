extends Panel

onready var label = $Label




func _on_AgainButton_button_up():
	GameController.Restart()
