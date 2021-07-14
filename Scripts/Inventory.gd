extends Control
class_name Inventory

export (NodePath) var inventorySlotsContainerPath

onready var moneyLabel = find_node("MoneyLabel")

var inventorySlotsContainer: GridContainer
var inventorySlots = []
var money: int = 100 setget set_money
var minRowNumber = 4

func _ready():
	Initialize()

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

func Full():
	for s in inventorySlots:
		if(!s.item): return false
	return true

func ShowPricetags(value):
	for s in inventorySlots:
		s.ShowPricetag(value)

func ClearAll():
	for s in inventorySlots:
		s.RemoveItem()

func AddSlot() -> SlotUI:
	var back = inventorySlotsContainer.get_child(inventorySlotsContainer.get_child_count() - 1)
	var newSlot = back.duplicate()
	newSlot.inventory = self
	newSlot.type = GameController.SLOT_INVENTORY
	inventorySlots.append(newSlot)
	inventorySlotsContainer.add_child(newSlot, true)
	if (back.item):
		var children = newSlot.container.get_children()
		for c in children:
			c.free()
	return newSlot

func AddRow():
	var columns = inventorySlotsContainer.columns
	for _i in range(columns):
		var newSlot = AddSlot()
		newSlot.type = GameController.SLOT_SHOP

func Sort():
	for i in range(inventorySlots.size() - 1, 0, -1):
		if (inventorySlots[i].item):
			var item = inventorySlots[i].item
			inventorySlots[i].RemoveItem()
			AddItem(item)

func TrimRows():
	Sort()
	var columns: int = inventorySlotsContainer.columns
	if((inventorySlots.size() / columns) <= minRowNumber): return
	while(!inventorySlots[inventorySlots.size() - columns].item):
		for i in range(inventorySlots.size() - 1, inventorySlots.size() - columns - 1, -1):
			inventorySlots[i].free()
			inventorySlots.pop_back()

func Initialize():
	inventorySlotsContainer = get_node(inventorySlotsContainerPath)
	inventorySlots = inventorySlotsContainer.get_children()
	for s in inventorySlots:
		s.inventory = self
		s.type = GameController.SLOT_INVENTORY
	moneyLabel.text = str(money)



func can_drop_data(_position, data):
	return (data.slot != null)

func drop_data(_position, data):
	data.slot.Put(data)

### setters/getters ###
func set_money(value):
	money = value
	moneyLabel.text = str(value)
######
