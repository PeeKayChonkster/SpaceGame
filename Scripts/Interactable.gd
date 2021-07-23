extends Node2D
class_name Interactable

onready var interactionArea = $Area2D

var interactable: bool = true
var interactPrompt: String = "Interact"

func _ready():
	interactionArea.connect("body_entered", self, "_on_Area2D_body_entered")
	interactionArea.connect("body_exited", self, "_on_Area2D_body_exited")

func Interact(_who):
	pass

func _on_Area2D_body_entered(body):
	if (interactable && "pilot" in body && body.pilot):
		body.pilot.OfferInteraction(self, interactPrompt)

func _on_Area2D_body_exited(body):
	if (interactable && "pilot" in body && body.pilot):
		body.pilot.DenyInteraction(self)
