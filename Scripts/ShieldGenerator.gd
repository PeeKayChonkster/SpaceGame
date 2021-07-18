extends Equipment

export(float) var maxEnergy
export(float) var timeBeforeRecharge
export(float) var chargeSpeed
export(Color) var color

onready var energy = maxEnergy #setget set_energy
onready var blockTimer = Timer.new()
onready var fieldSprite = $FieldSprite
onready var tween = Tween.new()

var blocked = false
var animating = false
var maxSpriteAlpha = 0.6


func _ready():
	add_child(blockTimer)
	add_child(tween)
	blockTimer.connect("timeout", self, "_BlockTimeout")
	fieldSprite.modulate = color
	fieldSprite.modulate.a = 0.0

func Recharge():
	while(equipped && !blocked && energy < maxEnergy):
		var delta = get_process_delta_time()
		self.energy += chargeSpeed * delta
		ship.SpendFuel(chargeSpeed, 1, delta)
		ship.UpdateUIBars(GameController.UPDATE_SHIELD)
		yield(Tools.CreateTimer(delta, self), "timeout")

# returns unblocked damage
func TakeDamage(dmg: float) -> float:
	blocked = true
	self.energy -= dmg
	blockTimer.start(timeBeforeRecharge)
	var unblocked = 0.0 
	ship.UpdateUIBars(GameController.UPDATE_SHIELD)
	if(energy < 0.0):
		unblocked = abs(energy)
		energy = 0.0
	else:
		AnimateHit()
	return unblocked

func AnimateHit():
	if(!animating):
		animating = true
		tween.interpolate_property(fieldSprite, "modulate:a", 0.0, maxSpriteAlpha, 0.01, Tween.TRANS_LINEAR)
		tween.start()
		yield(tween, "tween_completed")
		tween.interpolate_property(fieldSprite, "modulate:a", maxSpriteAlpha, 0.0, 0.3, Tween.TRANS_LINEAR, 2, 0.01)
		tween.start()
		yield(tween, "tween_completed")
		animating = false

func GetInventoryItem() -> InventoryItem:
	var inventoryItem = .GetInventoryItem()
	inventoryItem.values = {"energy" : energy}
	return inventoryItem

func GetValuesFromInventoryItem(item : InventoryItem):
	.GetValuesFromInventoryItem(item)
	if(item.values.has("energy")):
		### TakeDamage called instead of simple assignment, so that recharge will begin
		var _temp = TakeDamage(maxEnergy - item.values.energy)

func GetInformation():
	var info = .GetInformation()
	# remove description
	var _bul = info.pop_back()
	info.append("Max Energy: " + str(maxEnergy))
	info.append("Time Before Recharge: " + str(timeBeforeRecharge))
	info.append("Charge Speed: " + str(chargeSpeed))
	info.append("Description: " + description)
	return info

func _BlockTimeout():
	blocked = false
	Recharge()

### setters/getters ###
#func set_energy(value):
#	energy = value
#######
	
