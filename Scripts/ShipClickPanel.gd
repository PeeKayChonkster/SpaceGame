extends Panel

onready var ship = get_parent()

var enabled = false

func _on_ShipClickPanel_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == 1 && GameController.doubleclick):
		GameController.player.InteractWith(ship.pilotSeat.GetPilot())
	get_viewport().unhandled_input(event) ### forward inputEvent to other Nodes2D
