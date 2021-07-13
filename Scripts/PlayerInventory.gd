extends Inventory


#onready var inventoryUI = find_node("Inventory")
onready var shipUI = find_node("ship")
onready var shipTexture = GameController.FindNodeOrNull("ShipTexture", true, self)
onready var shipInventorySlotPrefab = preload("res://Scenes/UI/ShipInventorySlot.tscn")
onready var shieldBar = find_node("ShieldBar")
onready var hullBar = find_node("HullBar")
onready var fuelBar = find_node("FuelBar")
onready var moneyLabel = find_node("MoneyLabel")


var ship
var shipSlots = []

func _ready():
	while(ItemDatabase.items.empty()): yield(get_tree(), "idle_frame")
	AddItem(ItemDatabase.GetInventoryItem("MachineGun"))
	AddItem(ItemDatabase.GetInventoryItem("MachineGun"))
	AddItem(ItemDatabase.GetInventoryItem("TargetSystem"))
	AddItem(ItemDatabase.GetInventoryItem("Fuel"))
	Deactivate()

func Activate():
	UpdateBars(ship)
	moneyLabel.text = str(GameController.player.money)
	show()

func Deactivate():
	hide()

func SetShipUI(_ship: Ship):
	ship = _ship
	for slot in shipSlots:
		slot.queue_free()
	shipSlots.clear()
	
	shipTexture.texture = ship.inventoryTexture
	
	for slot in ship.slots:
		var newSlot = shipInventorySlotPrefab.instance()
		shipTexture.add_child(newSlot)
		newSlot.rect_position = slot.position + shipTexture.rect_size / 2.0 - newSlot.rect_size / 2.0
		newSlot._LinkWithShip(slot)
	
	SetBarsMaxValue(ship)

func ResetShipUI():
	shipTexture.set_deferred("texture", null)
	for slot in shipSlots:
		slot.queue_free()
	ship = null

func AddItem(item: InventoryItem):
	for slot in inventorySlots:
		if(slot.Empty()):
			slot.Put(item)
			return

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
