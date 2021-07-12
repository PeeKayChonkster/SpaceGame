extends Item


onready var bullet = $Bullet
onready var fireCone = $FireCone
onready var fireConePolygon = $FireCone/CollisionPolygon2D
onready var ship = get_parent().get_parent().get_parent()

export(float) var firerate = 1.0
export(float) var bulletSpeed = 1.0
export(float) var damage = 1.0
export(float) var fireRadius = 5000.0
export(float) var fireAngle = 30.0

var target
var drawVisibleFireCone = false
var working = false
var fireratePause = false
var fireConeColor = Color.green
var fireConeAlpha = 0.1
var animatingCone = false
var timer

### test
var firing = false
###

func _ready():
	fireConeColor.a = fireConeAlpha
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = firerate
	ship.connect("death", self, "_OnShipDeath", [], CONNECT_ONESHOT)

func _process(_delta):
	if (ship.pilot is NPC):
		Scan()
	else:
		WaitForFire()

func Scan():
	if(target && working):
		if(ship.targetSystem):
			if (ship.targetSystem.fireAllowed):
				Fire(true)
		else:
			Fire(false)

func WaitForFire():
	if(firing):
		if(ship.targetSystem):
			if (ship.targetSystem.fireAllowed):
				Fire(true)
		else:
			Fire(false)

func drawFireCone():
	var nb_points = 5
	var points_arc = PoolVector2Array()
	points_arc.push_back(position)
	var colors = PoolColorArray([fireConeColor])
	var angle_from = (-180 - fireAngle) / 2.0
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * fireAngle / nb_points)
		points_arc.push_back(position + Vector2(cos(angle_point), sin(angle_point)) * fireRadius)
	var fireConeShape = points_arc
	fireConePolygon.polygon = fireConeShape
	if(drawVisibleFireCone):
		draw_polygon(points_arc, colors)

func _draw():
	if(working || animatingCone):
		drawFireCone()

func AnimateCone(reverse = false):
	while(animatingCone): yield(get_tree(), "idle_frame")  ### wait for current animation to end
	animatingCone = true
	var radius = fireRadius
	var angle = fireAngle
	var animationSpeed = -0.1
	if (!reverse): 
		animationSpeed *= -1.0
		fireRadius = 0.0
		fireAngle = 0.0
	if (!reverse):
		while(fireRadius != radius):
			fireRadius += radius * animationSpeed
			fireRadius = clamp(fireRadius, 0.0, radius)
			update()
			yield(get_tree(), "idle_frame")
		while(fireAngle != angle):
			fireAngle += angle * animationSpeed
			fireAngle = clamp(fireAngle, 0.0, angle)
			update()
			yield(get_tree(), "idle_frame")
	else:
		while(fireAngle > 0.0):
			var a = angle * animationSpeed
			fireAngle += a
			fireAngle = clamp(fireAngle, 0.0, angle)
			update()
			yield(get_tree(), "idle_frame")
		while(fireRadius > 0.0):
			fireRadius += radius * animationSpeed
			fireRadius = clamp(fireRadius, 0.0, radius)
			update()
			yield(get_tree(), "idle_frame")
		fireRadius = radius
		fireAngle = angle
	animatingCone = false

func Fire(smart = false):
	if(!fireratePause):
		var newBullet = bullet.duplicate()
		GameController.world.add_child(newBullet)
		newBullet.global_position = global_position
		if (smart):
			newBullet.Fire(bulletSpeed, damage, ship, target, GetSmartTargetPoint(target))
		else:
			newBullet.Fire(bulletSpeed, damage, ship, target, null)
		
		FireOnPause()

### Prevent firing according to the firerate
func FireOnPause():
	fireratePause = true
	timer.start()
	yield(timer, "timeout")
	fireratePause = false

# derivation and formula for this is in the notebook (Предопределение направления выстрелa)
func GetSmartTargetPoint(_target) -> Vector2:
	var S = _target.global_position - global_position
	var Vs = _target.pilot.velocity
	var a = S.length_squared()
	var b = 2.0 * S.dot(Vs)
	var c = Vs.length_squared() - pow(bulletSpeed, 2.0)
	var D = pow(b, 2.0) - 4.0 * a * c
	var alpha1 = (-b + sqrt(D)) / (2.0 * a)
	var St1 = _target.global_position + _target.pilot.velocity / alpha1
	return St1

func SetFireConeShape(radius: float, degrees: int, color: Color):
	fireRadius = radius
	fireAngle = degrees
	fireConeColor = color
	fireConeColor.a = fireConeAlpha

func AddTarget(newTarget):
	#DebugWindow.OutputString("Adding target: " + newTarget.name)
	target = newTarget
	target.connect("death", self, "_OnTargetDeath")
	working = true
	AnimateCone()

func RemoveTarget():
	if(target):
		target.disconnect("death", self, "_OnTargetDeath")
		target = null
		working = false
		AnimateCone(true)

func GetInformation():
	var info = .GetInformation()
	# remove description
	var _bul = info.pop_back()
	info.append("Fire rate: " + str(firerate))
	info.append("Bullet speed: " + str(bulletSpeed))
	info.append("Damage: " + str(damage))
	info.append("Fire radius: " + str(fireRadius))
	info.append("fire angle: " + str(fireAngle))
	info.append("Description: " + description)
	return info

func _OnTargetDeath():
	RemoveTarget()

func _OnShipDeath():
	target.disconnect("death", self, "_OnTargetDeath")
	target = null
	working = false
