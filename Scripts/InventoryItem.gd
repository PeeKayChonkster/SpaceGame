extends Node
class_name InventoryItem

onready var iconPrefab = preload("res://Scenes/UI/InventoryIcon.tscn")

var selfScript = load("res://Scripts/InventoryItem.gd")

var itemName = name
var icon
var iconTexture: Texture
var itemType
var stackable: bool
var stackSize: int
var quantity: int setget set_quantity
var values = {}   # for conserving value of shieldGenerator energy, etc
var price: int setget set_price
var slot

func _init(_itemName:String, _iconTexture: Texture, _type, _stackable: bool, _stackSize: int, _quantity: int, _values: Dictionary, _price: int, _slot):
	itemName = _itemName
	iconTexture = _iconTexture
	itemType = _type
	stackable = _stackable
	stackSize = _stackSize
	quantity = _quantity
	values = _values
	slot = _slot
	icon = CreateIcon(iconTexture)
	self.price = _price

func CreateIcon(texture: Texture) -> TextureRect:
	if(!iconPrefab): iconPrefab = load("res://Scenes/UI/InventoryIcon.tscn")
	if(texture == null): push_error("Iventory item \"" + itemName + "\" doesn't have inventoryTexture")
	var newIcon = iconPrefab.instance()
	newIcon.texture = texture
	newIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	newIcon.expand = true
	newIcon.mouse_filter = Control.MOUSE_FILTER_PASS
	newIcon.find_node("NameLabel").text = itemName
	var quantityLabel = newIcon.find_node("QuantityLabel")
	quantityLabel.text = str(quantity)
	if(stackable): quantityLabel.show()
	return newIcon

func Split(value: int) -> InventoryItem:
	var portion = min(quantity, value)
	self.quantity -= portion
	var item = Duplicate()
	item.quantity = portion
	if(quantity <= 0.0): queue_free()
	return item
	###

func Duplicate():
	var newItem = selfScript.new(itemName, iconTexture, itemType, stackable, stackSize, quantity, values.duplicate(true), price, slot)
	return newItem

### setters/getters ###
func set_price(value):
	price = value
	icon.find_node("PricetagLabel").text = str(price)
	
func set_quantity(value):
	quantity = value
	icon.find_node("QuantityLabel").text = str(quantity)
#######################
