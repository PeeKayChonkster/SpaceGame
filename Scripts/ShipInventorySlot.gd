extends SlotUI

export(ItemDatabase.ITEM_TYPE) var itemType

var shipSlotNode   ### node on the ship

func _ready():
	Initialize()

func Initialize():
	.Initialize()
	while(!inventory): yield(get_tree(), "idle_frame")
	inventory.shipSlots.append(self)

func _LinkWithShip(slot):
	shipSlotNode = slot
	slot.shipInventorySlot = self
	# if ship has item, add it to this slot
	if (shipSlotNode.item && !item):
		while(!GameController.initialized): yield(get_tree(), "idle_frame")
		Put(shipSlotNode.item.GetInventoryItem(), false)
	itemType = shipSlotNode.itemType
	$Label.text = ItemDatabase.GetTypeAsString(itemType)

func Put(newItem: InventoryItem, instantiate = true):
	.Put(newItem)
	if(instantiate):
		var item = ItemDatabase.GetItem(newItem.itemName)
		shipSlotNode.add_child(item)
		shipSlotNode.ship.InitializeSlots()
		item.GetValuesFromInventoryItem(newItem)
		shipSlotNode.Update()

func RemoveItem():
	shipSlotNode.item.free()
	shipSlotNode.Update()
	shipSlotNode.ship.InitializeSlots()
	.RemoveItem()

#func get_drag_data(_position):
#	if(item):
#		var newControl = Control.new()
#		var newIcon = item.icon.duplicate()
#		newIcon.get_node("NameLabel").show()
#		newControl.add_child(newIcon)
#		newIcon.rect_position += -0.5 * newIcon.rect_size
#		set_drag_preview(newControl)
#		var sendItem = shipSlotNode.item.GetInventoryItem()
#		RemoveItem()
#		return sendItem
#	else:
#		return null

func drop_data(position, data):
	if(data.itemType == itemType):
		Put(data)
	else:
		data.slot.Put(data)

func _on_ShipInventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(shipSlotNode.item)
