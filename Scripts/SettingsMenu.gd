extends Panel


func _on_BackButton_button_up():
	GameController.ui.DeactivateSettingsMenu()


func _on_FogQualitySlider_value_changed(value):
	MapManager.proceduralSpaceBackground.SetFogQuality(value)
