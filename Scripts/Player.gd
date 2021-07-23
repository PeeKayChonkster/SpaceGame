extends Node2D
class_name Player

export (NodePath) var shipPath

onready var destReticlePrefab = preload("res://Scenes/UI/DestinationReticle.tscn")
onready var ship: KinematicBody2D = get_parent().get_parent()


var camera
var controller
var inventory
var moveTarget = null
var velocity = Vector2(0.0, 0.0)
var destReticle
var screenTouch: bool = false
var interactDistance = 50.0
var followTarget
var dead = false
var attackTarget
var lastCursorScreenPosition = Vector2.ZERO
var moveCursor
var initialized = false
# from 0 to 1. Shows how much of a thrust must be used. Used by SetExaust(), CalculateVelocity()
var accelerationCoef: float

func _ready():
	Initialize()

func _process(_delta):
	if(!dead):
		### extra
		ship.SetExaust(accelerationCoef)
		###

func _physics_process(delta):
	if(initialized && !dead):
		CalculateVelocity(delta)
		#velocity = ship.move_and_slide(velocity, Vector2.ZERO, false, 4, 0.0, false)
		var collision = ship.move_and_collide(velocity * delta, false)
		if(collision):
			ship.CheckForCollision(collision)

func CalculateVelocity(delta):
	var cursorDist
	var dir: Vector2
	
	# Calculate accelerationCoef based on controllMode an cursorDist
	if(controller.controllMode == 1 && !followTarget):
		var vec = (moveCursor.rect_global_position + moveCursor.rect_size / 2.0) - (moveCursor.get_parent().rect_global_position + moveCursor.get_parent().rect_size / 2.0)
		cursorDist = vec.length()
		dir = vec.normalized()
		accelerationCoef = cursorDist / GameController.maxMoveCursorDist
	elif(moveTarget):
		cursorDist = min((moveTarget - ship.global_position).length(), GameController.maxMoveTargetDist)
		dir = (moveTarget - ship.global_position).normalized()
		accelerationCoef = cursorDist / GameController.maxMoveTargetDist
	
	# Calculate velocity increment
	if (moveTarget != null && ship.engine && ship.fuel > 0.0): 
		var linearAcceleration = (ship.engine.thrust * 70.0) / ship.mass
		velocity += dir * linearAcceleration * accelerationCoef * delta
		velocity = velocity.clamped(ship.engine.maxSpeed)
		# friction
		
		velocity -= (pow(sin(dir.angle_to(velocity)), 4.0) * velocity * (1.0 - accelerationCoef) + velocity * (1.0 - accelerationCoef)) * 0.02
		
#		if(is_equal_approx(accelerationCoef, 0.0)):
#			velocity += -velocity.normalized() * linearAcceleration * delta
		
		
		Rotate(delta, dir)
		ship.SpendFuel(ship.engine.thrust * accelerationCoef, 0,delta)
		
		#### Extra
		camera.SetDynamicZoomRatio((velocity.length() + cursorDist / ((get_viewport().size.x + get_viewport().size.y) / 3.0)) / ship.engine.maxSpeed / 2.0)
		#DebugWindow.OutputVec2(velocity, true)
		####
		
	# Slowly stop if no fuel or engine
	else:
		# if no engine
		velocity += -velocity * 0.05

func Rotate(delta, dir: Vector2):
	if (!dir.is_equal_approx(Vector2.ZERO)):
		var angularAcceleration = ship.engine.torque * 0.8 / ship.mass
		var angle = lerp_angle(ship.transform.get_rotation() - PI/2.0, dir.angle(), angularAcceleration * delta)
		#DebugWindow.OutputString("angle = " + str(angle * (180.0/PI)))
		ship.rotation = angle + PI/2.0

func Land(planet: Planet):
	GameController.Pause(true)
	yield(ship.Land(), "completed")   ### wait for animation to play itself out
	ResetTargets(true)
	planet.ActivateUI()

func TakeOff(planet: Planet):
	GameController.Pause(false)
	ship.global_position = planet.global_position
	velocity = Vector2.ZERO
	ship.TakeOff()

func AddAttackTarget(target):
	if(attackTarget == target || target.mode == GameController.SHIPMODE_DEAD): return
	if(attackTarget): RemoveAttackTarget()
	attackTarget = target
	attackTarget.connect("death", self, "_OnTargetDeath")
	ship.AddTarget(target)
	### draw fireCones if weapons belong to player
	for slot in ship.slots:
		if(slot.itemType == ItemDatabase.ITEM_TYPE.WEAPON && slot.item):
			slot.item.drawVisibleFireCone = true
	ResetTargets()
	GameController.ui.ActivateAttackUI(target)

func RemoveAttackTarget():
	attackTarget.disconnect("death", self, "_OnTargetDeath")
	attackTarget = null
	ship.RemoveTarget()

# Uses global mouse position for setting moveTarget for mouse and touch
func SetReticle():
	lastCursorScreenPosition = get_viewport().get_mouse_position()
	moveCursor.get_parent().rect_global_position = lastCursorScreenPosition - moveCursor.get_parent().rect_size / 2.0
	moveCursor.get_parent().modulate.a = 1.0
	while(screenTouch || followTarget):   ### keep reseting reticle
		var globalMouse = get_global_mouse_position()
		
		# create reticle
		if(!destReticle && controller.controllMode == 2):
			destReticle = destReticlePrefab.instance()
			GameController.world.add_child(destReticle)
			
		if (controller.controllMode == 2):
			destReticle.global_position = globalMouse
		
		if(followTarget): 
			moveTarget = followTarget.global_position
		else: 
			moveTarget = global_position
			var vec1 = lastCursorScreenPosition
			var vec2 = get_viewport().get_mouse_position() - vec1
			if(vec2.length() > GameController.maxMoveCursorDist): vec2 = vec2.normalized() * GameController.maxMoveCursorDist
			moveCursor.rect_global_position = vec1 + vec2 - moveCursor.rect_size / 2.0
		yield(get_tree(), "idle_frame")

func Follow(object):
	followTarget = object
	SetReticle()

func Unfollow():
	followTarget = null

func InteractWith(object):
	#DebugWindow.OutputString("Interacting with " + object.name)
	ResetTargets()
	if(object.has_method("Interact")):
		object.Interact(self)
	else:
		printerr("Trying to interact with object that doesn't have Interact() method. " + "Object: " + object.name)

func DecreaseSpeed(target = null, multiplier = 0.01):
	ResetTargets(true)
	while(velocity.length() > 10.0):
		if(target):
			moveTarget = target.global_position
		velocity *= (1.0 - multiplier)
		yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

func Die():
	dead = true

# for planets and etc. to offer interaction to the pilot
func OfferInteraction(target, buttonPrompt: String = "Interact"):
	 # activate interact button
	GameController.ui.playerUI.ActivateInteractButton(target, buttonPrompt) 
	
	# rerender button until it's deactivated from the outside
	while(GameController.ui.playerUI.interactButton.visible):  
		if(velocity.length() < GameController.maxInteractVelocity):
			GameController.ui.playerUI.DisableInteractButton(false)
		else:
			GameController.ui.playerUI.DisableInteractButton(true)
		yield(Tools.CreateTimer(get_physics_process_delta_time(), self), "timeout")

# for planets to stop offering landing to the pilot
func DenyInteraction():
	GameController.ui.playerUI.DeactivateInteractButton()

func ResetTargets(resetMoveTarget = false):
	if(resetMoveTarget):
		moveTarget = null
	#screenTouch = false
	followTarget = null
	if(destReticle):
		destReticle.queue_free()
		destReticle = null

func Move(pos: Vector2):
	ResetTargets(true)
	ship.global_position = pos
	camera.global_position = pos

# keep moveCursor transparent if there is no input
#func handleMoveCursor():
#	if(!screenTouch && !followTarget):
#		var idlePosition = moveCursor.get_parent().rect_size / 2.0 - moveCursor.rect_size / 2.0
#		moveCursor.rect_position = lerp(moveCursor.rect_position, idlePosition, 0.2)
#		moveCursor.get_parent().modulate.a = max((moveCursor.rect_position - idlePosition).length() / maxMoveCursorDist - 0.05, 0.0)

func Initialize():
	camera = get_node("Camera2D")
	if(!ship):
		ship = get_node(shipPath)
	controller = get_node("PlayerController")
	ResetTargets(true)
	
	while(!GameController.initialized): yield(get_tree(), "idle_frame")
	moveCursor = GameController.ui.moveCursor
	moveCursor.get_parent().visible = (controller.controllMode == 1)
	GameController.ui.SetShipUI(ship)
	inventory = GameController.ui.inventoryUI
	initialized = true

func _OnTargetDeath():
	RemoveAttackTarget()
