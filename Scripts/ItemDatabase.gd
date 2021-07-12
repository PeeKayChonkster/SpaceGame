extends Node

enum ITEM_TYPE { WEAPON, TARGET_SYSTEM, ENGINE, SHIELD_GENERATOR, FUEL }

var items = {}
var ships = {}

var itemLoadPaths = [
	"res://Scenes/Items/",
]
var shipLoadPaths = [
	"res://Scenes/Ships/"
]

var typeStr = {
	ITEM_TYPE.WEAPON : "Weapon",
	ITEM_TYPE.TARGET_SYSTEM : "Target System",
	ITEM_TYPE.ENGINE: "Engine",
	ITEM_TYPE.SHIELD_GENERATOR: "Shield Generator",
	ITEM_TYPE.FUEL: "Fuel"
}

func LoadAll():
	for path in itemLoadPaths:
		LoadItems(path)
	for path in shipLoadPaths:
		LoadShips(path)

func LoadItems(path: String):
	var dir = Directory.new()
	if (dir.dir_exists(path)):
		dir.change_dir(path)
		dir.list_dir_begin(true)
		while(true):
			var nextName: String = dir.get_next()
			if (nextName == ""): break
			if(dir.current_is_dir()):
				LoadItems(path + nextName + "/")
				continue
			var filePath = path + nextName
			var newItem = ResourceLoader.load(filePath)
			nextName = nextName.replace(".tscn", "")
			items[nextName] = newItem
		dir.list_dir_end()

func LoadShips(path: String):
	var dir = Directory.new()
	if (dir.dir_exists(path)):
		dir.change_dir(path)
		dir.list_dir_begin(true)
		while(true):
			var nextName = dir.get_next()
			if (nextName == ""): break
			if(dir.current_is_dir()):
				LoadShips(path + nextName + "/")
				continue
			var filePath = path + nextName
			var newShip = ResourceLoader.load(filePath)
			ships[newShip.resource_name] = newShip
		dir.list_dir_end()

### Get inventory item as a packed scene, give him InventoryItem optionally
func GetItem(itemName: String):
	var item = items.get(itemName)
	if(!item): 
		push_error("Can't find item \"" + itemName + "\" in itemDatabase")
		return
	item = item.instance()
	return item

func GetInventoryItem(itemName: String):
	var item = GetItem(itemName)
	if(item == null): return
	var invItem = item.GetInventoryItem()
	item.queue_free()
	return invItem

func GetShip(shipName: String):
	return (ships.get(shipName))

func GetTypeAsString(type):
	return typeStr[type]
