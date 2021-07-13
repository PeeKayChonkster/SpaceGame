extends SlotUI
class_name InventorySlot

var type

func _ready():
	Initialize()

func Initialize():
	.Initialize()

func Put(newItem: InventoryItem):
	if(newItem.slot && newItem.slot.type != type):
		MakeTransaction(newItem)
		return
	.Put(newItem)

func MakeTransaction(item):
	if(item.price > inventory.money):  ### not enough money
		item.slot.Put(item)
	else:
		inventory.money -= item.price
		item.slot.inventory.money += item.price
		var oldItemSlot = item.slot
		.Put(item)
		
		# find out which inventory(receiving or sending) is shop
		# and refresh prices
		if(inventory is Shop): inventory.RefreshShopPrices()
		else: oldItemSlot.inventory.RefreshShopPrices()
		
		###########
		### Make money sound here
		###########
		return true

func RemoveItem():
	.RemoveItem()

func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
