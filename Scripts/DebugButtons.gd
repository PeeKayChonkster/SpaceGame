extends Control


func _on_StarButton_button_up():
	var _x = MapManager.SpawnRandomStar(GameController.player.global_position);


func _on_PlanetButton_button_up():
	var _x = MapManager.SpawnRandomPlanet(GameController.player.global_position);


func _on_SystemButton_button_up():
	var _x = MapManager.SpawnRandomStarSystem(GameController.player.global_position)


func _on_ClearButton_button_up():
	MapManager.ClearAllCosmicBodies()
