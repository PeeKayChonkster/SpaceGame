extends RigidBody2D
class_name Meteor


export(float) var size = 1.0 setget set_size

onready var sprite = $Sprite
onready var collisionPolygon = $CollisionPolygon2D
onready var explosionParticlesPrefab = preload("res://Scenes/Effects/ShipExplosion.tscn")

onready var initialScaleCollisionPolygon = collisionPolygon.scale
onready var initialScaleSprite = sprite.scale
onready var is_ready = true

var life = 100.0

func _ready():
	set_size(size)

func TakeDamage(damage: float, _who = null):
	life -= damage
	if(life <= 0.0):
		Explode()

func Explode():
	var particles = explosionParticlesPrefab.instance()
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
	life = pow(size, 2.0) * 30.0
	mass = size * 4000.0
#######################
