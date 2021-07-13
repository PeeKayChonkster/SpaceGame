extends Panel
class_name SlotUI


onready var container = $MarginContainer


var inventory

var visiblePricetag = false

var item: InventoryItem = null

func _ready():
	Initialize()

func Initialize():
	pass

func Put(newItem: InventoryItem):
	if(item):
		var oldItem = item
		RemoveItem()
		newItem.slot.Put(oldItem)
	item = newItem
	container.add_child(item.icon)
	if(item.stackable): item.icon.get_node("QuantityLabel").show()
	else:  item.icon.get_node("QuantityLabel").hide()
	ShowPricetag(visiblePricetag)
	item.slot = self

# virtual function for derivatives of this class. Deletes item, 
# corresponding to InventoryItem, from SceneTree()
func RemoveItem():
	container.remove_child(item.icon)
	item = null

func Empty():
	return (item == null)

func ShowPricetag(value: bool):
	visiblePricetag = value
	if(item): 
		var pricetag = item.icon.find_node("Pricetag")
		pricetag.visible = value
		pricetag.get_node("PricetagLabel").text = str(item.price)

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
	Put(data)

func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
