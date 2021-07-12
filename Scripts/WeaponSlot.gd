extends Node2D


var item = null

func _ready():
	Update()

func Update():
	if(get_child_count() != 0):
		item = get_child(0)
