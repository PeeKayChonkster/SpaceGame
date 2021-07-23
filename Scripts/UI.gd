extends CanvasLayer

export(bool) var DebugUI = false

onready var debugButtons = $DebugButtons
onready var playerUI = $PlayerUI
onready var minimap = $MiniMap
onready var attackUI = $AttackUI
onready var gameOverUI = $GameOverUI
onready var loadingScreen = $LoadingScreen
onready var inventoryUI = $InventoryUI
onready var itemDescriptionWindow = $ItemDescriptionWindow
onready var moveCursor = $MoveCursorBackground/MoveCursor
onready var startMenu = $StartMenu
onready var pauseMenu = $PauseMenu
onready var settingsMenu = $SettingsMenu
onready var splitItemsUI = $SplitItemsUI

func _ready():
	ToggleDebugUI(DebugUI)

func ToggleDebugUI(value = !debugButtons.visible):
	debugButtons.visible = !value

func ClearMinimap():
	minimap.Clear()

func RefreshMinimap():
	minimap.LoadItems()

func AppendMinimap(item):
	minimap.Append(item)

func ActivateAttackUI(target: Object):
	attackUI.Activate(target)

func ActivateGameOverUI():
	gameOverUI.show()

func ActivateLoadingScreen():
	loadingScreen.Activate()

func DeactivateLoadingScreen():
	loadingScreen.Deactivate()

func SetLoadingScreenPercent(value: int):
	loadingScreen.SetProgressPercent(value)

func ActivateInventory():
	inventoryUI.Activate()
	GameController.Pause(true)

func DeactivateInventory():
	inventoryUI.Deactivate()
	GameController.Pause(false)

func ActivateItemDescriptionWindow(item: Item):
	itemDescriptionWindow.Activate(item)

func DeactivateItemDescriptionWindow():
	itemDescriptionWindow.Deactivate()

func SetShipUI(ship):
	inventoryUI.SetShipUI(ship)

func ActivateStartMenu():
	startMenu.show()

func DeactivateStartMenu():
	startMenu.hide()

func ActivatePauseMenu():
	GameController.Pause(true)
	pauseMenu.show()

func DeactivatePauseMenu():
	GameController.Pause(false)
	pauseMenu.hide()

func ActivateSettingsMenu():
	settingsMenu.show()

func DeactivateSettingsMenu():
	settingsMenu.hide()

func ActivateSplitItemsUI(minValue: int, maxValue: int, price: int):
	splitItemsUI.Activate(minValue, maxValue, price)

func DeactivateSplitItemsUI():
	splitItemsUI.Deactivate()
