extends Control
class_name Inventory

export (NodePath) var inventorySlotsContainerPath

onready var moneyLabel = find_node("MoneyLabel")

var inventorySlotsContainer: GridContainer
var inventorySlots = []
var money: int = 20 setget set_money

func _ready():
	Initialize()

func Activate():
	show()

func Deactivate():
	hide()

func AddItem(item: InventoryItem) -> bool:
	for slot in inventorySlots:
		if(slot.Empty()):
			if(item.slot && item.slot.type != slot.type):
				print("Transaction")
				slot.MakeTransaction() ###<----------------------------
			slot.Put(item)
			return true
	return false

func ShowPricetags(value):
	for s in inventorySlots:
		s.ShowPricetag(value)

func RefreshPricetags():
	ShowPricetags(true)

func ClearAll():
	for s in inventorySlots:
		s.RemoveItem()

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
