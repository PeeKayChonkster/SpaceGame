extends SlotUI
class_name InventorySlot

func _ready():
	Initialize()

func Initialize():
	.Initialize()

#func Put(newItem: InventoryItem):
#	if(newItem.slot && newItem.slot.type != type):
#		return MakeTransaction(newItem)
#	return .Put(newItem)

#func MakeTransaction(item) -> int:
#	if(item.price * item.quantity > inventory.money):  ### not enough money
#		var difference: int = inventory.money / item.price
#		if(difference > 0):
#			var item1 = item.Split(difference)
#			item.slot.Put(item)
#			return .Put(item1)
#		else:
#			item.slot.Put(item)
#			return 0
#	else:
#		var oldItemSlot = item.slot
#
#		### decide on where to put item
#		if(item):     ### slot is occupied
#			if(inventory.Full()):  ### return item if inventory is full, or add row if this is a shop
#				if(inventory is Shop):
#					inventory.AddRow();
#					item.slot = self
#					inventory.AddItem(item);
#				else:
#					item.slot.Put(item)
#					return 0
#			else:
#				item.slot = self    ### add item to the first empty slot
#				inventory.AddItem(item)
#		else:
#			item.slot.Put(item)    ### slot is empty
#
#		inventory.money -= item.price * item.quantity
#		oldItemSlot.inventory.money += item.price * item.quantity
#
#		# find out which inventory(receiving or sending) is of class Shop
#		# and refresh prices
#		if(inventory is Shop): inventory.RefreshShopPrices()
#		else: oldItemSlot.inventory.RefreshShopPrices()
#
#		###########
#		### Make money sound here
#		###########
#		return item.quantity

func RemoveItem():
	.RemoveItem()

func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
