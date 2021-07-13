extends Inventory

func _ready():
	while(ItemDatabase.items.empty()): yield(Tools.CreateTimer(get_process_delta_time(), self), "timeout")
	AddItem(ItemDatabase.GetInventoryItem("MachineGun"))
	AddItem(ItemDatabase.GetInventoryItem("MachineGun"))
	AddItem(ItemDatabase.GetInventoryItem("TargetSystem"))
	AddItem(ItemDatabase.GetInventoryItem("Fuel"))
	AddItem(ItemDatabase.GetInventoryItem("TestEngine"))
	AddItem(ItemDatabase.GetInventoryItem("TestShieldGenerator"))
	
	ShowPriceTags(true)
	Deactivate()

func AddItem(item: InventoryItem):
	### if all slots are occupied
	if(!.AddItem(item)):
		AddSlotRow()
		AddItem(item)

func AddSlotRow():
	var slotsInRow = inventorySlotsContainer.columns
	for i in range(slotsInRow):
		var newSlot = inventorySlots.back().duplicate()
		newSlot.RemoveItem()
		newSlot.inventory = self
		add_child(newSlot)
