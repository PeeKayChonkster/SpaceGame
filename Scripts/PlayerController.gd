extends Node2D

enum ControllMode { TOUCH = 1, MOUSE = 2}

var destReticlePrefab = preload("res://Scenes/UI/DestinationReticle.tscn")

var player: Node2D
var controllMode = ControllMode.TOUCH

func _ready():
	player = get_parent()


func _unhandled_input(event):
	##### MOVING #####
	if(OS.has_touchscreen_ui_hint()):
		if (event is InputEventScreenTouch):
			player.camera.dynamic = true   ### <-test
			if(event.is_pressed()):
				player.screenTouch = true
				# don't move cursor if pause
				if(!get_tree().paused):
					player.SetReticle()
				player.Unfollow()
			else:
				player.screenTouch = false
	else:
		if (event is InputEventMouseButton):
			if(event.button_index == 1):
				player.camera.dynamic = true   ### <-test
				if (event.pressed):
					player.screenTouch = true
					# don't move cursor if pause
					if(!get_tree().paused):
						player.SetReticle()
					player.Unfollow()
				else:
					player.screenTouch = false
			if(event.button_index == BUTTON_WHEEL_UP):
				player.camera.dynamic = false
				player.camera.zoom += Vector2(event.factor, event.factor) * get_process_delta_time() * 100.0
			if(event.button_index == BUTTON_WHEEL_DOWN):
				player.camera.dynamic = false
				if(player.camera.zoom.x > 1.0 && player.camera.zoom.y > 1.0):
					player.camera.zoom -= Vector2(event.factor, event.factor) * get_process_delta_time() * 100.0
	#####################
	
	##### ACTIONS ######
	if(event.is_action_pressed("P")):
		var _x = MapManager.SpawnRandomPlanet(player.global_position)
	if(event.is_action_pressed("O")):
		var _x = MapManager.SpawnRandomStar(player.global_position)
	if(event.is_action_pressed("M")):
		var _x = MapManager.SpawnRandomStarSystem(player.global_position)
	if(event.is_action_pressed("C")):
		MapManager.ClearAllCosmicBodies()
	if(event.is_action_pressed("ShowDebugUI")):
		GameController.ui.ToggleDebugUI()
	if(event.is_action_pressed("space")):
		GameController.Pause()
	if(event.is_action_pressed("ui_cancel")):
		if(!GameController.ui.startMenu.visible):
			GameController.ui.ActivatePauseMenu()
	####################

func ScreenToWorld(point:Vector2) -> Vector2 :
	return get_canvas_transform().affine_inverse().xform(point)
