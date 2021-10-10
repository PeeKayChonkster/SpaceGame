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

func AddItem(item: InventoryItem, slot = null) -> bool:
	var itemQuantity = item.quantity
	
	if (slot):
		itemQuantity -= slot.Put(item)
		if(itemQuantity <= 0):
			return true
	
	for slot in inventorySlots:
		if(slot.Empty() || (item.stackable && item.itemName == slot.item.itemName && slot.item.quantity < slot.item.stackSize)):
			itemQuantity -= slot.Put(item)
			if(itemQuantity <= 0):
				return true
	
	if(item.slot):
		item.slot.inventory.AddItem(item, item.slot)
	return false

func BuyItem(item: InventoryItem, slot = null):
	var itemQuantity = item.quantity
	var initialQuantity = item.quantity
	var oldSlot = item.slot
	var oldPrice = item.price
	
	### Check if inventory has enough money, correct input quantity accordingly
	if(money < item.quantity * item.price):
		var affordableQuantity = money / item.price
		if(affordableQuantity == 0):  ### can't buy even 1 piece
			oldSlot.inventory.AddItem(item, oldSlot)
			return
		var item1 = item.Split(affordableQuantity)
		var temp = item
		item = item1
		item1 = temp
		itemQuantity = item.quantity
		initialQuantity= item.quantity
		item1.slot.inventory.AddItem(item1, item1.slot)
	
	### Activate splitUI
	if (item.quantity > 1):
		GameController.ui.ActivateSplitItemsUI(1, initialQuantity, oldPrice)
		while(!GameController.ui.splitItemsUI.answerIsReady && !GameController.ui.splitItemsUI.cancel):
			yield(get_tree(), "idle_frame")
		
		### Player clicked "Ok" button
		if(GameController.ui.splitItemsUI.answerIsReady):
			var newQuantity = GameController.ui.splitItemsUI.GetValue()
			if(newQuantity != initialQuantity):  ### skip splitting if player sells all possible quantity
				if(newQuantity != initialQuantity):
					var item1 = item.Split(newQuantity)
					var temp = item
					item = item1
					item1 = temp
					itemQuantity = newQuantity
					initialQuantity= newQuantity
					item1.slot.inventory.AddItem(item1, item1.slot)
		### Player clicked "Cancel" buttom
		else:
			oldSlot.inventory.AddItem(item, oldSlot)
			GameController.ui.DeactivateSplitItemsUI()
			return
	GameController.ui.DeactivateSplitItemsUI()
	
	### if there is specific slot as a function parameter
	### try to add item to this slot first
	if (slot):
		itemQuantity -= slot.Put(item)
		if(itemQuantity <= 0):
			oldSlot.inventory.money += initialQuantity * oldPrice
			self.money -= initialQuantity * oldPrice
			if(oldSlot.type == GameController.SLOT_SHOP): oldSlot.inventory.RefreshPrices()
			else: RefreshPrices()
			return true
	
	### finally add rest of the item to all other slots
	for slot in inventorySlots:
		if(slot.Empty() || (item.stackable && item.itemName == slot.item.itemName && slot.item.quantity < slot.item.stackSize)):
			itemQuantity -= slot.Put(item)
			if(itemQuantity <= 0):
				oldSlot.inventory.money += initialQuantity * oldPrice
				self.money -= initialQuantity * oldPrice
				if(oldSlot.type == GameController.SLOT_SHOP): oldSlot.inventory.RefreshPrices()
				else: RefreshPrices()
				return true
	
	### take/give money
	oldSlot.inventory.money += (initialQuantity - item.quantity) * oldPrice
	self.money -= (initialQuantity - item.quantity) * oldPrice
	### if we are here, then there's some item quantity that didn't
	### fit in the inventory. Put it back where it came from
	oldSlot.inventory.AddItem(item, oldSlot)
	
	return false

func RefreshPrices():
	pass

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
			var _full = AddItem(item)

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


### setters/getters ###
func set_money(value):
	money = value
	moneyLabel.text = str(value)
######
