extends SlotUI
class_name InventorySlot

var type

func _ready():
	Initialize()

func Initialize():
	.Initialize()

func Put(newItem: InventoryItem):
	if(newItem.slot && newItem.slot.type != type):
		print("Transaction")
	.Put(newItem)


func RemoveItem():
	.RemoveItem()

func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
