extends Node2D

export(int) var length = 10

onready var line = $Line2D


func _ready():
	line.set_as_toplevel(true)

func _process(_delta):
	AddPoint(global_position)

func AddPoint(pos: Vector2) -> void:
	line.add_point(pos)
	while(line.get_point_count() > length):
		line.remove_point(0)
