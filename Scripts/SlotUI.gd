extends Panel
class_name SlotUI


onready var container = $MarginContainer


var inventory

var visiblePricetag = true

var item: InventoryItem = null

var type

func _ready():
	Initialize()

func Initialize():
	pass

func Put(newItem: InventoryItem) -> int:
	var initialQuantity = newItem.quantity
	if(item):
		if(item.itemName == newItem.itemName):
			if(item.quantity < item.stackSize):
				var difference = min(newItem.quantity, item.stackSize - item.quantity)
				item.quantity += difference
				newItem.quantity -= difference
				if(newItem.quantity > 0): 
					return difference
				else:
					newItem.free()
					return initialQuantity
			else:
				return 0
		else:
			### if it's a transaction
			if(type != newItem.slot.type):
				return 0
			else:
				var oldItem = item
				RemoveItem()
				newItem.slot.Put(oldItem)
				Put(newItem)
				return initialQuantity
	else:
		item = newItem
		if (item.icon.get_parent()): item.icon.get_parent().remove_child(item.icon)
		container.add_child(item.icon)
		if(item.stackable): item.icon.get_node("QuantityLabel").show()
		else:  item.icon.get_node("QuantityLabel").hide()
		ShowPricetag(visiblePricetag)
		item.slot = self
		return initialQuantity

# virtual function for derivatives of this class. Deletes item, 
# corresponding to InventoryItem, from SceneTree()
func RemoveItem():
	if (item):
		container.remove_child(item.icon)
		item = null

func DestroyItem():
	if (item):
		item.icon.queue_free()
		item = null

func Empty():
	return (item == null)

func ShowPricetag(value: bool):
	visiblePricetag = value
	if(item): 
		var pricetag = item.icon.find_node("Pricetag")
		pricetag.visible = value

func get_drag_data(_position):
	if(item):
		var newControl = Control.new()
		var newIcon = item.icon.duplicate()
		newIcon.get_node("NameLabel").show()
		newControl.add_child(newIcon)
		newIcon.rect_position += -0.5 * newIcon.rect_size
		set_drag_preview(newControl)
		var sendItem = item
		RemoveItem()
		return sendItem
	else:
		return null

func can_drop_data(_position, data):
	return (data is InventoryItem)

func drop_data(_position, data):
	if(data.slot.type == type):
		inventory.AddItem(data, self)
	else:
		inventory.BuyItem(data, self)

func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
