extends Area2D



onready var particlesPrefab = preload("res://Scenes/Effects/BulletParticles.tscn")
onready var maxDistance = GameController.screenSize.x

var target
var point   #Vector2
var damage
var velocity
var initialPosition
var bulletOwner
var fired = false


func _physics_process(delta):
	Move(delta)

func Fire(speed: float, dmg, newOwner, _target, _point = null):
	if(!fired):
		target = _target
		newOwner.connect("death", self, "_OnOwnerDeath", [], CONNECT_ONESHOT)
		damage = dmg
		bulletOwner = newOwner
		point = _point
		var visibilityNotifier = VisibilityNotifier2D.new()
		add_child(visibilityNotifier)
		show()
		if(point):
			var dir = (point - global_position).normalized()
			velocity = dir * speed
			rotate(dir.angle())
		else:
			rotate(bulletOwner.rotation + PI / 2.0)
			velocity = -bulletOwner.transform.y.normalized() * speed
		initialPosition = global_position
		rotate(-PI / 2.0)
		fired = true

func Move(delta):
	if(fired):
		global_position += velocity * delta
		if ((initialPosition - global_position).length() > maxDistance):
			queue_free()

func _OnOwnerDeath():
	bulletOwner = null

func _on_Bullet_body_entered(body):
	if(body.has_method("TakeDamage") && bulletOwner && bulletOwner != body):
		var newParticles = particlesPrefab.instance()
		GameController.world.add_child(newParticles)
		newParticles.global_position = global_position
		body.TakeDamage(damage, bulletOwner)
		if(body is Ship && bulletOwner.pilot is Player):
			bulletOwner.pilot.AddAttackTarget(body)
		queue_free()
