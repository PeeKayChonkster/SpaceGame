extends Inventory


onready var inventoryContainer = get_node("InventoryContainer")


var playerInventory
var playerInventoryParent  ### for bringing playerInventory back
var activated = false

func _ready():
	Initialize()

func Activate():
	if(!activated):
		if(!playerInventory): playerInventory = GameController.ui.inventoryUI.inventoryPanel
		if(!playerInventoryParent): playerInventoryParent = playerInventory.get_parent()
		playerInventoryParent.remove_child(playerInventory)
		inventoryContainer.add_child(playerInventory)
		for s in GameController.ui.inventoryUI.inventorySlots:
			s.ShowPricetag(true)
		activated = true

func Deactivate():
	if(activated):
		inventoryContainer.remove_child(playerInventory)
		playerInventoryParent.add_child(playerInventory)
		for s in GameController.ui.inventoryUI.inventorySlots:
			s.ShowPricetag(false)
		activated = false

func Initialize():
	.Initialize()
	for s in inventorySlots:
		s.type = GameController.SLOT_SHOP
		s.ShowPricetag(true)
