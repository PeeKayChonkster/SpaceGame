extends SlotUI
class_name InventorySlot


func _ready():
	Initialize()

func Initialize():
	.Initialize()

func Put(newItem: InventoryItem):
	.Put(newItem)

func RemoveItem():
	.RemoveItem()


func _on_InventorySlot_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT && GameController.doubleclick && item):
		GameController.ui.ActivateItemDescriptionWindow(ItemDatabase.GetItem(item.itemName))
