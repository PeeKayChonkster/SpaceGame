extends Panel

onready var audioPlayer = $AudioStreamPlayer

func _on_StartGameButton_button_up():
	if(GameController.initialized):
		hide()
		GameController.StartGame()
		audioPlayer.stop()


func _on_ExitButton_button_up():
	if(GameController.initialized):
		audioPlayer.stop()
		GameController.ExitGame()


func _on_SettingsButton_pressed():
	GameController.ui.ActivateSettingsMenu()
