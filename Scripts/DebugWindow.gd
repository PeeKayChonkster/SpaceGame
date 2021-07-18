extends Control


onready var label = $RichTextLabel

var vectorsToDraw = []

func _ready():
	var _error = GameController.connect("ui_initialized", self, "_Initialize")

func _process(_delta):
	vectorsToDraw.clear()

func OutputString(string: String, clear: bool = false):
	if (clear) : label.text = "";
	label.text += "\n" + string

func OutputVec2(vec: Vector2, clear: bool = false):
	if (clear) : label.text = ""
	label.text += "\n" + "(" + str(vec.x) + " ; " + str(vec.y) + ")"

func DrawVector(point1: Vector2, point2: Vector2, color = Color.green):
	vectorsToDraw.append(VectorToDraw.new(point1, point2, color))
	update()

func _draw():
	for v in vectorsToDraw:
		draw_line(v.p1, v.p2, v.c)

func _Initialize(value):
	remove_child(label)
	value.add_child(label)

class VectorToDraw:
	var p1: Vector2
	var p2: Vector2
	var c: Color
	
	func _init(point1: Vector2, point2: Vector2, color = Color.green):
		p1 = point1
		p2 = point2
		c = color
