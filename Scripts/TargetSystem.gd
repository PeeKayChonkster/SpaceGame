extends Equipment

export(float) var workSpeedMultiplier

onready var reticle = $TargetSystemReticle

var fireAllowed = false
var target = null
var aiming = false

func _process(_delta):
	if(target): 
		reticle.position = target.global_position

func Aim(_target):
	if(!aiming):
		aiming = true
		target = _target
		reticle.connect("ready_to_fire", self, "_AllowFire")
		reticle.Aim(workSpeedMultiplier)

func Disaim():
	if (aiming || target):
		aiming = false
		target = null
		fireAllowed = false
		reticle.disconnect("ready_to_fire", self, "_AllowFire")
		reticle.StopAiming()

func GetInformation():
	var info = .GetInformation()
	# remove description
	var _bul = info.pop_back()
	info.append("Aim speed: " + str(workSpeedMultiplier))
	info.append("Description: " + description)
	return info

func _AllowFire():
	fireAllowed = true
