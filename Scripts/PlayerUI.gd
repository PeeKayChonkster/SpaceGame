extends Control


onready var hullBar = find_node("HullBar")
onready var shieldBar = find_node("ShieldBar")
onready var fuelBar = find_node("FuelBar")
onready var inventoryButton = $Buttons/InventoryButton
onready var interactButton = $Buttons/InteractButton
onready var attackModeButton = $AttackModeButton

var player
var interactionTarget = null
var tween: Tween

func _ready():
	var _error = GameController.connect("player_initialized", self, "_Initialize")
	interactButton.hide()
	tween = Tween.new()
	add_child(tween)


func Activate():
	show()

func Deactivate():
	player.ship.disconnect("hull_update", self, "_OnHullUpdate")
	player.ship.disconnect("shield_update", self, "_OnShieldUpdate")
	player.ship.disconnect("fuel_update", self, "_OnFuelUpdate")

func _OnTargetDeath():
	Deactivate()

func ActivateInteractButton(target, buttonPrompt: String):
	interactionTarget = target
	interactButton.text = buttonPrompt
	interactButton.show()

func DeactivateInteractButton():
	interactionTarget = null
	interactButton.hide()

func _OnHullUpdate():
	hullBar.value = player.ship.hullIntegrity

func _OnShieldUpdate():
	if(player.ship.shieldGenerator):
		shieldBar.value = player.ship.shieldGenerator.energy
	else:
		shieldBar.value = 0.0

func _OnFuelUpdate():
	fuelBar.value = player.ship.fuel

func _Initialize(value):
	player = value
	SetBarMaxValue(GameController.UPDATE_HULL, player.ship.maxHullIntegrity)
	SetBarMaxValue(GameController.UPDATE_FUEL, player.ship.fuelCapacity)
	if(player.ship.shieldGenerator):
		SetBarMaxValue(GameController.UPDATE_SHIELD, player.ship.shieldGenerator.maxEnergy)
	else:
		shieldBar.value = 0.0
	player.ship.connect("hull_update", self, "_OnHullUpdate")
	player.ship.connect("shield_update", self, "_OnShieldUpdate")
	player.ship.connect("fuel_update", self, "_OnFuelUpdate")
	player.ship.UpdateUIBars(GameController.UPDATE_HULL | GameController.UPDATE_SHIELD | GameController.UPDATE_FUEL)
	Activate()

func SetBarMaxValue(mask: int, value: float):
	if(mask & GameController.UPDATE_HULL):
		hullBar.max_value = value
	if(mask & GameController.UPDATE_SHIELD):
		shieldBar.max_value = value
	if(mask & GameController.UPDATE_FUEL):
		fuelBar.max_value = value


func _on_Panel_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == 1 && !event.pressed):
		#GameController.Pause()
		pass

func _on_InventoryButton_button_up():
	GameController.ui.ActivateInventory()

func _on_InteractButton_button_up():
	player.InteractWith(interactionTarget)


func _on_AttackModeButton_toggled(button_pressed):
	if(button_pressed):
		player.ship.mode = GameController.SHIPMODE_ATTACK
	elif(player.ship.mode != GameController.SHIPMODE_DEAD):
		player.ship.mode = GameController.SHIPMODE_IDLE
	var _err = tween.interpolate_property(attackModeButton, "rect_scale", Vector2(1.0, 1.0), Vector2(1.2, 1.2), 0.1)
	_err = tween.start()
	yield(Tools.CreateTimer(0.1, self), "timeout")
	_err = tween.interpolate_property(attackModeButton, "rect_scale", Vector2(1.2, 1.2), Vector2(1.0, 1.0), 0.1)
	_err = tween.start()

