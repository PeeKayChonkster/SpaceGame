extends Node2D


func GetPilot():
	if(get_child_count() == 0):
		return null
	else:
		return get_child(0)
