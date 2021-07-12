extends HBoxContainer

onready var npc = get_parent()

func Activate():
	npc.remove_child(self)
	GameController.ui.add_child(self)
	show()

func Deactivate():
	if (get_parent() == GameController.ui):
		GameController.ui.remove_child(self)
		npc.add_child(self)
	hide()
	GameController.Pause(false)

func _on_AttackPanel_gui_input(event):
	if (event is InputEventMouseButton && event.button_index == 1 && !event.pressed):
		GameController.player.AddAttackTarget(npc.ship)
		Deactivate()


func _on_FollowPanel_gui_input(event):
	if (event is InputEventMouseButton && event.button_index == 1 && !event.pressed):
		GameController.player.Follow(npc.ship)
		Deactivate()

func _unhandled_input(event):
	if (event is InputEventKey && event.scancode == KEY_ESCAPE):
		Deactivate()
