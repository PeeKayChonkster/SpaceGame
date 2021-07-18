extends Node2D
class_name ShipSlot

export(ItemDatabase.ITEM_TYPE) var itemType

var item = null
var shipInventorySlot
var ship

func Update():
	if(get_child_count() != 0):
		item = get_child(0)
		item.Equip()
	else:
		item = null
