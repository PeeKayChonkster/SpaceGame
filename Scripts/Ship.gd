extends KinematicBody2D
class_name Ship

const fuelToThrustRatio = 0.0003
const fuelToEnergyRatio = 0.1

export (float) var maxHullIntegrity
export (Texture) var inventoryTexture
export (float) var fuelCapacity
export (float) var mass = 1000.0
export (bool) var pilotIsPlayer = false
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
onready var trail = get_node("Trail")


var hullIntegrity: float
var fuel
var targetSystem = null
var engine = null
var shieldGenerator = null
var fuelTank = null
var mode = GameController.SHIPMODE_IDLE
var weapons = []

var initialized = false

signal hull_update
signal shield_update
signal fuel_update
signal death

func _ready():
	hullIntegrity = maxHullIntegrity
	fuel = fuelCapacity
	UpdateUIBars(GameController.UPDATE_HULL | GameController.UPDATE_FUEL | GameController.UPDATE_SHIELD)
	InitializeSlots()
	if (createPilotOnStart): CreatePilot()

func _physics_process(_delta):
	#position += wobble * 0.5
	pass

func CheckForCollision(collision):
	if(collision.collider is RigidBody2D):
		var resultVelocity = pilot.velocity - collision.collider.linear_velocity
		var damage = resultVelocity.length() * GameController.collisionVelocityDamageCoef
		
		### Take damage depending on collider 
		if(collision.collider.has_method("TakeDamage")):
			TakeDamage(collision.collider.TakeDamage(damage, self))
		### Take regular damage
		else:
			TakeDamage(damage)
		
		var body = collision.collider
		var v1 = pilot.velocity.project(collision.normal)
		var impulse =  (body.mass * mass / (body.mass + mass)) * v1  ###((body.mass * v2 + mass * v1) / (body.mass + mass)) * body.mass
		collision.collider.apply_impulse(collision.collider.to_local(collision.position), impulse)
		pilot.velocity -= impulse / mass

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
	ClearTrail()
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
		UpdateUIBars(GameController.UPDATE_SHIELD)
	hullIntegrity -= dmg
	UpdateUIBars(GameController.UPDATE_HULL)
	if(fromWho && !pilot.attackTarget):
		pilot.AddAttackTarget(fromWho)
	if(hullIntegrity < 0.0):
		Explode()

func UpdateUIBars(mask: int):
	if(mask & GameController.UPDATE_HULL):
		emit_signal("hull_update")
	if(mask & GameController.UPDATE_SHIELD):
		emit_signal("shield_update")
	if(mask & GameController.UPDATE_FUEL):
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
		slot.Update()
		slot.ship = self
		match(slot.itemType):
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
		if(GameController.initialized): GameController.ui.inventoryUI.UpdateBars(self)
	UpdateUIBars(GameController.UPDATE_HULL | GameController.UPDATE_SHIELD | GameController.UPDATE_FUEL)
	initialized = true

func Explode():
	mode = GameController.SHIPMODE_DEAD
	emit_signal("death")
	collisionPolygon.set_deferred("disabled", true)
	yield(Tools.CreateTimer(1.0, self), "timeout")
	
		# drop some equipped items
	for s in slots:
		if(s.item):
			if(GameController.rng.randf() < (1.0 / s.item.price) * GameController.itemDropChance):
				s.remove_child(s.item)
				yield(Tools.CreateTimer(get_process_delta_time(), self), "timeout")
				GameController.clutter.add_child(s.item, true)
				s.item.global_position = global_position + Tools.RandomVec(30.0)
				s.item.Unequip()
	
	EffectsManager.FlashScreen()
	EffectsManager.ShakeCamera()
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

### test
### enable fire if in attack mode, or disable fire
func Fire(value):
	if(mode == GameController.SHIPMODE_ATTACK || value == false):
		for weapon in weapons:
			weapon.firing = value

func SpendFuel(magnitude, whichRatio, delta):
	var coef
	match(whichRatio):
		0: coef = fuelToThrustRatio
		1: coef = fuelToEnergyRatio
	fuel -= magnitude * coef * delta
	fuel = max(0.0, fuel)
	UpdateUIBars(GameController.UPDATE_FUEL)

func CreatePilot():
	if (!pilot):
		var newPilot = playerPrefab.instance() if pilotIsPlayer else npcPrefab.instance()
		pilotSeat.add_child(newPilot)
		pilot = newPilot

func ClearTrail():
	for c in trail.get_children():
		c.Clear()
