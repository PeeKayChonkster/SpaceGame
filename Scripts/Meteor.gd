extends RigidBody2D
class_name Meteor


export(float) var size = 1.0 setget set_size

onready var sprite = $Sprite
onready var collisionPolygon = $CollisionPolygon2D
onready var explosionParticlesPrefab = preload("res://Scenes/Effects/ShipExplosion.tscn")

onready var initialScaleCollisionPolygon = collisionPolygon.scale
onready var initialScaleSprite = sprite.scale
onready var mineralPrefab = preload("res://Scenes/Items/Misc/Mineral.tscn")
onready var is_ready = true

var life = 100.0

func _ready():
	set_size(size)

func TakeDamage(damage: float, _who = null) -> float:
	var oldLife = life
	life -= damage
	if(life <= 0.0):
		Explode()
		return oldLife
	else:
		return damage

func Explode():
	var particles = explosionParticlesPrefab.instance()
	var drop: int = GameController.rng.randi_range(0, floor(3 * size))
	for _i in range(drop):
		if(GameController.rng.randf() > size): continue
		var newMineral = mineralPrefab.instance()
		newMineral.quantity = GameController.rng.randi_range(1, newMineral.stackSize)
		newMineral.global_position = global_position + Tools.RandomVec(30.0 * size)
		get_parent().call_deferred("add_child", newMineral)
	particles.scale = Vector2(size, size)
	particles.amount *= size
	GameController.world.add_child(particles)
	particles.global_position = global_position
	queue_free()

### setters/getters ###
func set_size(value):
	if(!is_ready): yield(self, "ready")
	size = value
	sprite.scale = initialScaleSprite * size
	collisionPolygon.scale = initialScaleCollisionPolygon * size
	life = pow(size, 2.0) * 200.0
	mass = size * 4000.0
#######################
