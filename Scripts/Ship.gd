extends Node2D
class_name Ship

enum UPDATE_BARS { HULL = 1, SHIELD = 2, FUEL = 4 }

const fuelToThrustRatio = 0.0003
const fuelToEnergyRatio = 0.1

export (float) var maxHullIntegrity
export (Texture) var inventoryTexture
export (float) var fuelCapacity
export (float) var mass = 1000.0
export (bool) var ownerIsPlayer = false
export (bool) var createPilotOnStart = true
# controls through animationPlayer
export var wobble: Vector2 = Vector2.ZERO

onready var exaust: Node2D = $Exaust
onready var animationPlayer = $AnimationPlayer
onready var pilotSeat = $PilotSeat
onready var pilot = pilotSeat.GetPilot()
onready var slots = get_node("Slots").get_children()
onready var shipExplosionPefab = preload("res://Scenes/Effects/ShipExplosion.tscn")
onready var playerPrefab = preload("res://Scenes/Player.tscn")
onready var npcPrefab = preload("res://Scenes/NPC.tscn")
onready var sprite = $Sprite
onready var collisionPolygon = $CollisionPolygon2D
onready var tween = $Tween
onready var initialScale = scale


var hullIntegrity: float
var fuel
var targetSystem = null
var engine = null
var shieldGenerator = null
var fuelTank = null
var weapons = []

signal hull_update
signal shield_update
signal fuel_update
signal death

func _ready():
	if (createPilotOnStart): CreatePilot()
	hullIntegrity = maxHullIntegrity
	fuel = fuelCapacity
	UpdateUIBars(UPDATE_BARS.HULL | UPDATE_BARS.FUEL | UPDATE_BARS.SHIELD)
	InitializeSlots()

func _physics_process(_delta):
	position += wobble * 0.5

func SetExaust(coef: float):
	if(engine):
		if(fuel > 0.0):
			exaust.scale.y = lerp(exaust.scale.y, coef, 0.1)
		else:
			exaust.scale.y = 0.0

func Land():
#	animationPlayer.play("Landing")
	tween.interpolate_property(self, "scale", initialScale, Vector2.ZERO, 1.0, Tween.TRANS_LINEAR)
	tween.start()
	while(tween.is_active()):
		yield(get_tree(), "idle_frame")
#	while(animationPlayer.is_playing()):
#		yield(get_tree(), "idle_frame")

func TakeOff():
	#animationPlayer.play("Takeoff")
	tween.interpolate_property(self, "scale", Vector2.ZERO, initialScale, 1.0, Tween.TRANS_LINEAR)
	tween.start()
	while(tween.is_active()):
		yield(get_tree(), "idle_frame")
	#while(animationPlayer.is_playing()):
	#	yield(get_tree(), "idle_frame")

func AddTarget(target):
	for weapon in weapons:
		weapon.AddTarget(target)
	if(targetSystem):
		targetSystem.Aim(target)

func RemoveTarget():
	for weapon in weapons:
		weapon.RemoveTarget()
	if(targetSystem):
		targetSystem.Disaim()

func TakeDamage(dmg, fromWho = null):
	if(hullIntegrity < 0.0): return
	if(shieldGenerator):
		dmg = shieldGenerator.TakeDamage(dmg)
		UpdateUIBars(UPDATE_BARS.SHIELD)
	hullIntegrity -= dmg
	UpdateUIBars(UPDATE_BARS.HULL)
	if(fromWho && !pilot.attackTarget):
		pilot.AddAttackTarget(fromWho)
	if(hullIntegrity < 0.0):
		Explode()

func UpdateUIBars(mask: int):
	if(mask & UPDATE_BARS.HULL):
		emit_signal("hull_update")
	if(mask & UPDATE_BARS.SHIELD):
		emit_signal("shield_update")
	if(mask & UPDATE_BARS.FUEL):
		emit_signal("fuel_update")

func TurnOffWeapons():
	for slot in slots:
		if(slot.type == ItemDatabase.ITEM_TYPE.WEAPON && slot.item):
			slot.item.RemoveTarget()

func InitializeSlots():
	targetSystem = null
	shieldGenerator = null
	weapons.clear()
	for slot in slots:
		match(slot.type):
			ItemDatabase.ITEM_TYPE.TARGET_SYSTEM: 
				targetSystem = slot.item
			ItemDatabase.ITEM_TYPE.WEAPON: 
				if (slot.item):
					weapons.append(slot.item)
			ItemDatabase.ITEM_TYPE.ENGINE:
				engine = slot.item
			ItemDatabase.ITEM_TYPE.SHIELD_GENERATOR:
				shieldGenerator = slot.item
			ItemDatabase.ITEM_TYPE.FUEL:
				fuelTank = slot.item
		slot.ship = self
		if(GameController.initialized): GameController.ui.inventoryUI.UpdateBars(self)
	if (pilot.attackTarget): pilot.AddAttackTarget(pilot.attackTarget)
	UpdateUIBars(UPDATE_BARS.HULL | UPDATE_BARS.SHIELD | UPDATE_BARS.FUEL)

func Explode():
	emit_signal("death")
	#collisionPolygon.set_deferred("disabled", true)
	yield(Tools.CreateTimer(1.0, self), "timeout")
	var newExplosion = shipExplosionPefab.instance()
	GameController.world.add_child(newExplosion)
	newExplosion.global_position = global_position
	if(pilotSeat.get_child(0) is Player):
		GameController.ui.ActivateGameOverUI()
		GameController.player.Die()
		remove_child(pilotSeat)
		GameController.world.add_child(pilotSeat)
		pilotSeat.global_position = global_position
	queue_free()

func SpendFuel(magnitude, whichRatio, delta):
	var coef
	match(whichRatio):
		0: coef = fuelToThrustRatio
		1: coef = fuelToEnergyRatio
	fuel -= magnitude * coef * delta
	fuel = max(0.0, fuel)
	UpdateUIBars(UPDATE_BARS.FUEL)

func CreatePilot():
	if (!pilot):
		var newPilot = playerPrefab.instance() if ownerIsPlayer else npcPrefab.instance()
		pilotSeat.add_child(newPilot)
		pilot = newPilot
