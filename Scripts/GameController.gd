extends Node

### All enums
enum { UPDATE_HULL = 1, UPDATE_SHIELD = 2, UPDATE_FUEL = 4 }
enum { SHIPMODE_IDLE, SHIPMODE_ATTACK, SHIPMODE_DEAD }
enum { SLOT_INVENTORY, SLOT_SHOP }
###

var player
var ui
var world
var clutter

var useThreads: bool = true
var doubleclickTime = 0.25
var clickTime = 0.0
var doubleclick = false
var initialized = false
var screenSize
var maxInteractVelocity = 100.0
var itemDropChance = 10.0

var collisionVelocityDamageCoef = 0.01

var maxMoveTargetDist = 600.0    # responsible for (speed / targetDistance) ratio
var maxMoveCursorDist = 150.0    # responsible for (speed / CursorDistance) ratio


onready var rng = RandomNumberGenerator.new()

signal player_initialized
signal ui_initialized
signal world_initialized

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	yield(Initialize(), "completed")

func _process(delta):
	clickTime += delta

func FindNodeOrNull(name:String, recursive = false, parent = get_tree().root):
	var node = parent.get_node_or_null(name)
	if (recursive && node == null):
		for n in parent.get_children():
			node = FindNodeOrNull(name, true, n)
			if (node): break
	return node

func Pause(state: bool = !get_tree().paused):
	get_tree().paused = state

func _input(event):
	if (event is InputEventMouseButton && event.button_index == 1 && event.pressed):
		if(clickTime < doubleclickTime):
			doubleclick = true
			clickTime = 0.0
			yield(get_tree(), "idle_frame")
			doubleclick = false
		else:
			clickTime = 0.0

func StartGame():
	
	GameController.ui.ActivateLoadingScreen()
	GameController.ui.SetLoadingScreenPercent(0)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	GameController.ui.ClearMinimap()
	MapManager.ClearAllCosmicBodies()
	var newStarSystem = MapManager.SpawnRandomStarSystem(Vector2.ZERO)
	MapManager.currentSystem = newStarSystem.GetInfo().id
	
	
	GameController.ui.SetLoadingScreenPercent(50)
	yield(get_tree(), "idle_frame")
	
	ItemDatabase.LoadAll()
	
	GameController.ui.RefreshMinimap()
	
	GameController.ui.SetLoadingScreenPercent(100)
	# wait for player camera to move
	yield(get_tree().create_timer(1.0), "timeout")
	GameController.ui.DeactivateLoadingScreen()

func ExitGame():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func ChangeSystem(stargate):
	Pause(true)
	yield(player.ship.Land(), "completed")
	Pause(false)
	
	GameController.ui.ActivateLoadingScreen()
	GameController.ui.SetLoadingScreenPercent(0)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	GameController.ui.ClearMinimap()
	var newStarSystem
	if(stargate.destinationSystemID): 
		newStarSystem = MapManager.SpawnStarSystem(stargate)
	else: 
		newStarSystem = MapManager.SpawnRandomStarSystem(Vector2.ZERO, stargate)
	
	MapManager.currentSystem = newStarSystem.GetInfo().id
	
	
	# remove starsystem from the tree, so we can clear all old cosmicBodies
	MapManager.cosmicBodies.remove_child(newStarSystem)
	
	GameController.ui.SetLoadingScreenPercent(50)
	yield(get_tree(), "idle_frame")
	
	MapManager.ClearAllCosmicBodies()
	yield(get_tree(), "idle_frame")
	MapManager.cosmicBodies.add_child(newStarSystem)
	
	GameController.ui.RefreshMinimap()
	
	GameController.ui.SetLoadingScreenPercent(100)
	GameController.ui.DeactivateLoadingScreen()
	
	Pause(true)
	yield(player.ship.TakeOff(), "completed")
	Pause(false)

func Initialize():
	player = null
	world = null
	ui = null
	
	get_tree().set_quit_on_go_back(false)
	screenSize = OS.get_screen_size()
	
	while(!player):
		player = FindNodeOrNull("Player", true)
		yield(get_tree(), "idle_frame")
	emit_signal("player_initialized", player)
	
	while(!ui):
		ui = FindNodeOrNull("UI", true)
		yield(get_tree(), "idle_frame")
	emit_signal("ui_initialized", ui)
	
	while(!world):
		world = FindNodeOrNull("World", true)
		yield(get_tree(), "idle_frame")
	emit_signal("world_initialized", ui)
	
	while(!clutter):
		clutter = FindNodeOrNull("Clutter", true)
		yield(get_tree(), "idle_frame")
	
	initialized = true

### doesn't work anymore
func Restart():
	var _error = get_tree().change_scene("res://Scenes/TestWorld.tscn")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	Initialize()
	pass
