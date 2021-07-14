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
		var oldItemSlot = item.slot
		
		### decide on where to put item
		if(item):     ### slot is occupied
			if(inventory.Full()):  ### return item if inventory is full
				item.slot.Put(item)
				return
			else:
				item.slot = self    ### add item to the first empty slot
				inventory.AddItem(item)
		else:
			item.slot.Put(item)    ### slot is empty
		
		inventory.money -= item.price
		oldItemSlot.inventory.money += item.price
		
		# find out which inventory(receiving or sending) is of class Shop
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
