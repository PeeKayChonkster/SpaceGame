extends Control


onready var hullBar = $MainPanel/VBoxContainer/HullBar
onready var shieldBar = $MainPanel/VBoxContainer/ShieldBar
onready var fuelBar = $MainPanel/VBoxContainer/FuelBar
onready var inventoryButton = $Buttons/InventoryButton
onready var interactButton = $Buttons/InteractButton

var player
var interactionTarget = null

func _ready():
	var _error = GameController.connect("player_initialized", self, "_Initialize")
	interactButton.hide()


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
	SetBarMaxValue(Ship.UPDATE_BARS.HULL, player.ship.maxHullIntegrity)
	SetBarMaxValue(Ship.UPDATE_BARS.FUEL, player.ship.fuelCapacity)
	if(player.ship.shieldGenerator):
		SetBarMaxValue(Ship.UPDATE_BARS.SHIELD, player.ship.shieldGenerator.maxEnergy)
	else:
		shieldBar.value = 0.0
	player.ship.connect("hull_update", self, "_OnHullUpdate")
	player.ship.connect("shield_update", self, "_OnShieldUpdate")
	player.ship.connect("fuel_update", self, "_OnFuelUpdate")
	player.ship.UpdateUIBars(Ship.UPDATE_BARS.HULL | Ship.UPDATE_BARS.SHIELD | Ship.UPDATE_BARS.FUEL)
	Activate()

func SetBarMaxValue(mask: int, value: float):
	if(mask & Ship.UPDATE_BARS.HULL):
		hullBar.max_value = value
	if(mask & Ship.UPDATE_BARS.SHIELD):
		shieldBar.max_value = value
	if(mask & Ship.UPDATE_BARS.FUEL):
		fuelBar.max_value = value

func _on_Panel_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == 1 && !event.pressed):
		GameController.Pause()

func _on_InventoryButton_button_up():
	GameController.ui.ActivateInventory()

func _on_InteractButton_button_up():
	player.InteractWith(interactionTarget)
