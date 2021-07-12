extends Node2D
class_name ShipSlot

export(ItemDatabase.ITEM_TYPE) var type

var item = null
var shipInventorySlot
var ship

func _ready():
	while(!ship): yield(get_tree(), "idle_frame")
	Update()

func Update():
	if(get_child_count() != 0):
		item = get_child(0)
		item.GetValuesFromInventoryItem()
	else:
		item = null
	ship.InitializeSlots()
