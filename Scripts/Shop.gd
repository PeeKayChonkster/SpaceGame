extends Inventory
class_name Shop

onready var inventoryContainer = get_node("InventoryContainer")


var playerInventory
var playerInventoryParent  ### for bringing playerInventory back
var activated = false
var defaultShopCoef: float = 1.2
var shopCoefs = {}

func _ready():
	Initialize()

func Activate():
	if(!activated):
		if(!playerInventory): playerInventory = GameController.ui.inventoryUI.inventoryPanel
		if(!playerInventoryParent): playerInventoryParent = playerInventory.get_parent()
		playerInventoryParent.remove_child(playerInventory)
		inventoryContainer.add_child(playerInventory)
		for s in GameController.ui.inventoryUI.inventorySlots:
			if(s.item):
				ChangeItemPrice(s.item, true)
		GameController.ui.inventoryUI.RefreshPricetags()
		activated = true

func Deactivate():
	if(activated):
		inventoryContainer.remove_child(playerInventory)
		playerInventoryParent.add_child(playerInventory)
		for s in GameController.ui.inventoryUI.inventorySlots:
			if(s.item):
				s.item.price = ItemDatabase.GetInventoryItem(s.item.itemName).price
		GameController.ui.inventoryUI.RefreshPricetags()
		activated = false

func ChangeItemPrice(item: InventoryItem, sellingPrice: bool):
	var stockPrice = ItemDatabase.GetInventoryItem(item.itemName).price
	if(shopCoefs.has(item.itemName)):
		### change stock price to shop price
		item.price = stockPrice / shopCoefs[item.itemName] if(sellingPrice) else stockPrice * shopCoefs[item.itemName]
	else:
		### add item to shopCoefs list
		item.price = stockPrice / defaultShopCoef if(sellingPrice) else stockPrice * defaultShopCoef
		shopCoefs[item.itemName] = defaultShopCoef

func RefreshShopPrices():
	for s in GameController.ui.inventoryUI.inventorySlots:
		if(s.item):
			ChangeItemPrice(s.item, true)
	GameController.ui.inventoryUI.RefreshPricetags()
	
	for s in inventorySlots:
		if(s.item):
			ChangeItemPrice(s.item, false)
	RefreshPricetags()

func Initialize():
	.Initialize()
	money = 200
	for s in inventorySlots:
		s.type = GameController.SLOT_SHOP
		s.ShowPricetag(true)
