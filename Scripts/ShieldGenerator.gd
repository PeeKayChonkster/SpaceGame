extends Item

export(float) var maxEnergy
export(float) var timeBeforeRecharge
export(float) var chargeSpeed
export(Color) var color

onready var energy = maxEnergy setget _set_energy
onready var blockTimer = Timer.new()
onready var sprite = $Sprite
onready var ship = get_parent().get_parent().get_parent()
onready var tween = Tween.new()

var blocked = false
var animating = false
var maxSpriteAlpha = 0.6

func _ready():
	add_child(blockTimer)
	add_child(tween)
	blockTimer.connect("timeout", self, "_BlockTimeout")
	sprite.modulate = color
	sprite.modulate.a = 0.0

func Recharge():
	while(!blocked && energy < maxEnergy):
		var delta = get_process_delta_time()
		self.energy += chargeSpeed * delta
		ship.SpendFuel(chargeSpeed, 1, delta)
		ship.UpdateUIBars(Ship.UPDATE_BARS.SHIELD)
		yield(Tools.CreateTimer(delta), "timeout")

# returns unblocked damage
func TakeDamage(dmg: float) -> float:
	blocked = true
	self.energy -= dmg
	blockTimer.start(timeBeforeRecharge)
	var unblocked = 0.0
	if(energy < 0.0):
		unblocked = abs(energy)
		energy = 0.0
	else:
		AnimateHit()
	return unblocked

func AnimateHit():
	if(!animating):
		animating = true
		tween.interpolate_property(sprite, "modulate:a", 0.0, maxSpriteAlpha, 0.01, Tween.TRANS_LINEAR)
		tween.start()
		yield(tween, "tween_completed")
		tween.interpolate_property(sprite, "modulate:a", maxSpriteAlpha, 0.0, 0.3, Tween.TRANS_LINEAR, 2, 0.01)
		tween.start()
		yield(tween, "tween_completed")
		animating = false

func GetInventoryItem() -> InventoryItem:
	var inventoryItem = .GetInventoryItem()
	inventoryItem.values = {"energy" : energy}
	return inventoryItem

func GetValuesFromInventoryItem():
	.GetValuesFromInventoryItem()
	if(inventoryItem.values.has("energy")):
		### TakeDamage called instead of simple assignment, so that recharge will begin
		var _temp = TakeDamage(maxEnergy - inventoryItem.values.energy)

func _BlockTimeout():
	blocked = false
	Recharge()

### setters/getters ###
func _set_energy(value):
	.UpdateInventoryItemValue("energy", value)
	energy = value
#######
	
