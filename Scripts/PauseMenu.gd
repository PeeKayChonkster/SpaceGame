extends Panel




func _on_ExitButton_button_up():
	GameController.ExitGame()


func _on_ResumeButton_button_up():
	GameController.ui.DeactivatePauseMenu()
