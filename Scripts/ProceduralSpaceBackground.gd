extends Sprite


onready var fog1 = find_node("ProceduralFog1")
onready var fog2 = find_node("ProceduralFog2")
onready var fog3 = find_node("ProceduralFog3")

export (bool) var parallax = true

var initialized = false
var camera

var fogShader1
var fogShader2
var fogShader3

func _ready():
	Initialize()

func Parallax():
	while(parallax):
		var cameraPos = camera.global_position
		cameraPos.y *= -1.0
		fogShader2.set_shader_param("shift", cameraPos * 0.00001)
		fogShader3.set_shader_param("shift", cameraPos * 0.00002)
		yield(get_tree(), "idle_frame")

func Randomize():
	pass

func Initialize():
	fogShader1 = fog1.material
	fogShader2 = fog2.material
	fogShader3 = fog3.material
	while(!GameController.initialized): yield(get_tree(), "idle_frame")
	camera = GameController.player.camera
	initialized = true
	Parallax()
