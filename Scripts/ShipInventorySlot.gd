extends InventorySlot

export(ItemDatabase.ITEM_TYPE) var type

var shipSlotNode   ### node on the ship

func _ready():
	_onReady()

func _onReady():
	inventory.shipSlots.append(self)

func _LinkWithShip(slot):
	shipSlotNode = slot
	slot.shipInventorySlot = self
	# if ship has item, add it to this slot
	if (shipSlotNode.item && !item):
		while(!GameController.initialized): yield(get_tree(), "idle_frame")
		Put(shipSlotNode.item.GetInventoryItem(), false)
	type = shipSlotNode.type
	$Label.text = ItemDatabase.GetTypeAsString(type)

func Put(newItem: InventoryItem, instantiate = true):
	.Put(newItem)
	if(instantiate):
		shipSlotNode.add_child(ItemDatabase.GetItem(newItem.itemName))
		shipSlotNode.item.GetValuesFromInventoryItem(newItem)
		shipSlotNode.Update()

func RemoveItem():
	shipSlotNode.item.free()
	shipSlotNode.Update()
	.RemoveItem()

func get_drag_data(_position):
	if(item):
		var newControl = Control.new()
		var newIcon = item.icon.duplicate()
		newIcon.get_node("NameLabel").show()
		newControl.add_child(newIcon)
		newIcon.rect_position += -0.5 * newIcon.rect_size
		set_drag_preview(newControl)
		var sendItem = shipSlotNode.item.GetInventoryItem()
		RemoveItem()
		return sendItem
	else:
		return null

func drop_data(position, data):
	if(data.type == type):
		.drop_data(position, data)
	else:
		data.slot.Put(data)

func _on_ShipInventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(shipSlotNode.item)
