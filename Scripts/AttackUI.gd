extends Control


onready var panel = $Panel
onready var label = $Panel/CenterContainer/NameLabel
onready var hullBar = $Panel/CenterContainer/VBoxContainer/HullBar
onready var shieldBar = $Panel/CenterContainer/VBoxContainer/ShieldBar

var target

func _ready():
	hide()

func Activate(newTarget: Object):
	if(target == newTarget): return
	if(target):
		Deactivate()
	target = newTarget
	target.connect("death", self, "_OnTargetDeath")
	target.connect("hull_update", self, "_OnHullUpdate")
	target.connect("shield_update", self, "_OnShieldUpdate")
	label.text = target.name
	hullBar.max_value = target.maxHullIntegrity
	hullBar.value = target.hullIntegrity
	if(target.shieldGenerator):
		shieldBar.max_value = target.shieldGenerator.maxEnergy
		shieldBar.value = target.shieldGenerator.energy
	else:
		shieldBar.value = 0.0
	show()

func Deactivate():
	target.disconnect("death", self, "_OnTargetDeath")
	target.disconnect("hull_update", self, "_OnHullUpdate")
	target.disconnect("shield_update", self, "_OnShieldUpdate")
	target = null
	hide()

func _OnHullUpdate():
	hullBar.value = target.hullIntegrity

func _OnShieldUpdate():
	shieldBar.value = target.shieldGenerator.energy

func _OnTargetDeath():
	Deactivate()

func _on_Panel_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == 1 && !event.pressed):
		GameController.player.RemoveAttackTarget()
		Deactivate()
