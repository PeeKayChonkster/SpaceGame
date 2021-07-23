extends Node2D
class_name NPC

enum NPC_TYPE {friendly, hostile}
enum NPC_STATE {idle, attack, follow, chase}

export (NodePath) var shipPath
export(NPC_TYPE) var type
export(float) var visionRadius

onready var ship = get_parent().get_parent()   ### pilotSeat -> ship
onready var npc = get_parent()
onready var visionCollider = $VisionArea2D/CollisionShape2D
onready var interactUI = $NPCInteractUI

var state: int
var moveTarget
var attackTarget
var followTarget
var velocity = Vector2.ZERO
# from 0 to 1. Shows how much of a thrust must be used. Used by SetExaust(), CalculateVelocity()
var accelerationCoef: float

func _ready():
	if(!ship):
		ship = get_node(shipPath)
	ChangeState(NPC_STATE.idle)

func _process(_delta):
	ship.SetExaust(accelerationCoef)

func _physics_process(delta):
	Cycle()
	CalculateVelocity(delta)
	velocity = ship.move_and_slide(velocity)

func ChangeState(newState: int):
	state = newState
	ResetTargets(true)

func Cycle():
	match(state):
		NPC_STATE.idle: Idle()
		NPC_STATE.attack: Attack()
		NPC_STATE.follow: Follow()
		NPC_STATE.chase: Chase()

func Idle():
	if(type == NPC_TYPE.friendly):
		pass
	else:
		pass
	pass

func Attack():
	moveTarget = attackTarget.global_position

func Follow():
	pass

func Chase():
	pass

func SetVisionRadius(newRadius:float):
	visionRadius = newRadius
	visionCollider.shape.radius = newRadius

func AddAttackTarget(newTarget):
	if(attackTarget || newTarget == attackTarget): return
	attackTarget = newTarget
	attackTarget.connect("death", self, "_OnTargetDeath")
	ship.AddTarget(newTarget)
	ChangeState(NPC_STATE.attack)

func RemoveAttackTarget():
	attackTarget.disconnect("death", self, "_OnTargetDeath")
	attackTarget = null
	ship.RemoveTarget()

func ResetTargets(resetMoveTarget = false):
	if(resetMoveTarget):
		moveTarget = global_position + global_transform.x.rotated(-PI/2.0)
	followTarget = null

# for planets to offer landing to the pilot
func OfferInteraction(_target, _buttonPromt = "Interact"):
	pass

# for planets to stop offering landing to the pilot
func DenyInteraction(_target):
	pass

func Interact(_who):
	GameController.Pause(true)
	interactUI.Activate()
	pass

####### MOVEMENT #######

func CalculateVelocity(delta):
	var linearAcceleration = (ship.engine.thrust * 70.0) / ship.mass
	var cursorDist = min((moveTarget - ship.global_position).length(), GameController.maxMoveTargetDist)
	var dir = (moveTarget - ship.global_position).normalized()
	accelerationCoef = cursorDist / GameController.maxMoveTargetDist
	velocity += dir * linearAcceleration * accelerationCoef * delta
	velocity = velocity.clamped(ship.engine.maxSpeed)
	# friction
	velocity -= (pow(sin(dir.angle_to(velocity)), 4.0) * velocity * (1.0 - accelerationCoef) + velocity * (1.0 - accelerationCoef)) * 0.02
	
#	if(is_equal_approx(accelerationCoef, 0.0)):
#		velocity += -velocity.normalized() * linearAcceleration * delta
	
	### Old friction system. It may be for npc better after all
	#velocity += -velocity * (ship.engine.breaks / ship.mass) * (1.0 - accelerationCoef) * delta
	###
	
	Rotate(delta, dir)

func Rotate(delta, dir: Vector2):
	var angularAcceleration = ship.engine.torque * 0.8 / ship.mass
	var angle = lerp_angle(ship.transform.get_rotation() - PI/2.0, dir.angle(), angularAcceleration * delta)
	#DebugWindow.OutputString("angle = " + str(angle * (180.0/PI)))
	ship.rotation = angle + PI/2.0

#########################


func _on_VisionArea2D_body_entered(body):
	if("pilotSeat" in body):
		var pilot = body.pilotSeat.get_child(0)
		if(pilot is Player):
			if(type == NPC_TYPE.friendly):
				pass
			elif(type == NPC_TYPE.hostile):
				AddAttackTarget(body)

func _OnTargetDeath():
	ChangeState(NPC_STATE.idle)
	RemoveAttackTarget()
	### Here i have to check if there is more enemies in the vision area, instead
	### of just changing state to idle!!!
