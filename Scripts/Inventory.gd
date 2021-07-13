extends Control
class_name Inventory

export (NodePath) var inventorySlotsContainerPath


var inventorySlotsContainer: GridContainer
var inventorySlots = []


func _ready():
	inventorySlotsContainer = get_node(inventorySlotsContainerPath)
	inventorySlots = inventorySlotsContainer.get_children()
	for s in inventorySlots:
		s.inventory = self
	Deactivate()

func Activate():
	show()

func Deactivate():
	hide()

func AddItem(item: InventoryItem) -> bool:
	for slot in inventorySlots:
		if(slot.Empty()):
			slot.Put(item)
			return true
	return false

func ShowPriceTags(value):
	if(value != null):
		for s in inventorySlots:
			s.ShowPricetag(value)

func can_drop_data(_position, data):
	return (data.slot != null)

func drop_data(_position, data):
	data.slot.Put(data)
