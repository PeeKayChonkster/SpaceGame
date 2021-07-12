extends Sprite
class_name Stargate


onready var minimapIcon = "stargate"

var destinationSystemID
var currentSystemID


func Interact(who):
	if(who is Player):
		GameController.ChangeSystem(self)
	else:
		pass

func GetInfo() -> StargateInfo:
	var info = StargateInfo.new()
	info.name = name
	info.position = global_position
	info.destinationSystemID = destinationSystemID
	info.currentSystemID = currentSystemID
	info.id = hash(position) + hash(name)
	return info

func _on_Area2D_body_entered(body):
	if ("pilot" in body && body.pilot):
		body.pilot.OfferInteraction(self, "Travel")

func _on_Area2D_body_exited(body):
	if ("pilot" in body && body.pilot):
		body.pilot.DenyInteraction()


class StargateInfo:
	var name
	var id
	var position: Vector2
	var destinationSystemID
	var currentSystemID
