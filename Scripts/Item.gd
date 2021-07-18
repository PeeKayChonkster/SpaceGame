extends Interactable
class_name Item

export(String) var itemName = name
export(Texture) var inventoryTexture
export(String, MULTILINE) var description
export(ItemDatabase.ITEM_TYPE) var type
export(bool) var stackable = false
export(int) var stackSize = 1
export(float) var quantity = 1
export(int) var price = 10

onready var sprite = find_node("Sprite")

func _ready():
	#get_parent().item = self
	interactPrompt = "Pick Up: " + itemName

func Interact(who):
	.Interact(who)
	if("inventory" in who):
		if(who.inventory.AddItem(GetInventoryItem())):
			queue_free()

func GetInventoryItem() -> InventoryItem:
	### override this in children to assign values to t
	return InventoryItem.new(itemName, inventoryTexture, type, stackable, stackSize, quantity, {}, price, null)

#func UpdateInventoryItemValue(key: String, value):
#	inventoryItem.values[key] = value

func GetValuesFromInventoryItem(_item : InventoryItem):
	# abstract #
	### get required info from inventoryItem values dictionary
	pass

func GetInformation():
	var info = []
	info.append("Name: " + itemName)
	info.append("Type: " + ItemDatabase.GetTypeAsString(type))
	info.append("Price: " + str(price))
	info.append("Description: " + description)
	return info
