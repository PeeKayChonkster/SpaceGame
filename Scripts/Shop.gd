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
		activated = true

func Deactivate():
	if(activated):
		inventoryContainer.remove_child(playerInventory)
		playerInventoryParent.add_child(playerInventory)
		for s in GameController.ui.inventoryUI.inventorySlots:
			if(s.item):
				s.item.price = ItemDatabase.GetInventoryItem(s.item.itemName).price
		TrimRows()
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

func RefreshPrices():
	.RefreshPrices()
	if(activated):
		for s in GameController.ui.inventoryUI.inventorySlots:
			if(s.item):
				ChangeItemPrice(s.item, true)
	
	for s in inventorySlots:
		if(s.item):
			ChangeItemPrice(s.item, false)

func AddItem(item: InventoryItem, slot = null):
	if (!.AddItem(item, slot)):
		AddRow()
		AddItem(item, slot)

func BuyItem(item: InventoryItem, slot = null):
	if (!.BuyItem(item, slot)):
		AddRow()
		.BuyItem(item, slot)

func Initialize():
	while(ItemDatabase.items.empty()): yield(get_tree(), "idle_frame")
	.Initialize()
	money = 200
	var quantity = GameController.rng.randi_range(1, 20)
	for _i in range(quantity):
		AddItem(ItemDatabase.GetRandomInventoryItem())
	for s in inventorySlots:
		s.type = GameController.SLOT_SHOP
		s.ShowPricetag(true)
	RefreshPrices()
