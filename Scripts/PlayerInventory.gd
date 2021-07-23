extends Inventory


#onready var inventoryUI = find_node("Inventory")
onready var shipUI = find_node("ship")
onready var shipTexture = find_node("ShipTexture")
onready var shipInventorySlotPrefab = preload("res://Scenes/UI/ShipInventorySlot.tscn")
onready var shieldBar = find_node("ShieldBar")
onready var hullBar = find_node("HullBar")
onready var fuelBar = find_node("FuelBar")
onready var inventoryPanel = find_node("Inventory")
onready var closeButton = find_node("CloseButton")


var ship
var shipSlots = []

func _ready():
	while(ItemDatabase.items.empty()): yield(get_tree(), "idle_frame")
	var _err = AddItem(ItemDatabase.GetInventoryItem("FuelCrystal"))
	_err = AddItem(ItemDatabase.GetInventoryItem("FuelCrystal"))
	_err = AddItem(ItemDatabase.GetInventoryItem("MachineGun"))
	Deactivate()

func Activate():
	UpdateBars(ship)
	show()

func Deactivate():
	hide()

func AddItem(item: InventoryItem, slot = null):
	if(!.AddItem(item, slot)):
		if(item.slot):
			item.slot.Put(item)
		return false
	return true;

func SetShipUI(_ship: Ship):
	ship = _ship
	for slot in shipSlots:
		slot.queue_free()
	shipSlots.clear()
	
	shipTexture.texture = ship.inventoryTexture
	
	for slot in ship.slots:
		var newSlot = shipInventorySlotPrefab.instance()
		newSlot.type = GameController.SLOT_INVENTORY
		newSlot.ShowPricetag(false)
		shipTexture.add_child(newSlot)
		newSlot.rect_position = slot.position + shipTexture.rect_size / 2.0 - newSlot.rect_size / 2.0
		newSlot._LinkWithShip(slot)
	
	SetBarsMaxValue(ship)

func ResetShipUI():
	shipTexture.set_deferred("texture", null)
	for slot in shipSlots:
		slot.queue_free()
	ship = null

func UpdateBars(ship):
	hullBar.value = ship.hullIntegrity
	fuelBar.value = ship.fuel
	if (ship.shieldGenerator != null):
		shieldBar.value = ship.shieldGenerator.energy
	else:
		shieldBar.value = 0.0

func SetBarsMaxValue(_ship):
	hullBar.max_value = _ship.maxHullIntegrity
	fuelBar.max_value = _ship.fuelCapacity
	if (_ship.shieldGenerator):
		shieldBar.max_value = _ship.shieldGenerator.maxEnergy
	else:
		shieldBar.value = 0.0

func _on_CloseButton_button_up():
	GameController.ui.DeactivateInventory()
