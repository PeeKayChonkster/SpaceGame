extends Sprite


onready var fog1 = find_node("ProceduralFog1")
onready var fog2 = find_node("ProceduralFog2")
onready var fog3 = find_node("ProceduralFog3")

export (bool) var parallax = true

var initialized = false
var camera
var fogSetups = {}   ## key = systemID, value = array of fog colors

var fogShader1
var fogShader2
var fogShader3

func _ready():
	Initialize()

func Parallax():
	while(parallax):
		var cameraPos = camera.global_position
		cameraPos.y *= -1.0
		if(fog3.visible):
			fogShader3.set_shader_param("shift", cameraPos * 0.00005)
		if(fog2.visible):
			fogShader2.set_shader_param("shift", cameraPos * 0.0001)
		if(fog1.visible):
			fogShader1.set_shader_param("shift", cameraPos * 0.0002)
		yield(get_tree(), "idle_frame")

func GenerateFogColor(systemID: int):
	var setups = []
	
	if(fogSetups.has(systemID)):
		setups = fogSetups[systemID]
	else:
		var rng = GameController.rng
		for _i in range(3):
			var r = rng.randf_range(0.0, 1.0)
			var g = rng.randf_range(0.0, 1.0)
			var b = rng.randf_range(0.0, 1.0)
			var a = rng.randf_range(0.2, 0.6)
			var density = rng.randf_range(0.15, 0.3)
			var period = rng.randi_range(1, 5)
			var shift = Tools.RandomVec(500.0)
			setups.append(FogSetup.new(Color(r, g, b, a), density, period, shift))
		fogSetups[systemID] = setups
	
	fogShader1.set_shader_param("color", setups[0].color)
	fogShader1.set_shader_param("density", setups[0].density)
	fogShader1.set_shader_param("period", setups[0].period)
	fogShader1.set_shader_param("shift", setups[0].shift)
	
	fogShader2.set_shader_param("color", setups[1].color)
	fogShader2.set_shader_param("density", setups[1].density)
	fogShader2.set_shader_param("period", setups[1].period)
	fogShader2.set_shader_param("shift", setups[1].shift)
	
	fogShader3.set_shader_param("color", setups[2].color)
	fogShader3.set_shader_param("density", setups[2].density)
	fogShader3.set_shader_param("period", setups[2].period)
	fogShader3.set_shader_param("shift", setups[2].shift)

func Initialize():
	fogShader1 = fog1.material
	fogShader2 = fog2.material
	fogShader3 = fog3.material
	while(!GameController.initialized): yield(get_tree(), "idle_frame")
	camera = GameController.player.camera
	initialized = true
	Parallax()

### value from 0 to 3
func SetFogQuality(value: int):
	match(value):
		0:
			fog1.hide()
			fog2.hide()
			fog3.hide()
		1:
			fog1.show()
			fog2.hide()
			fog3.hide()
		2:
			fog1.show()
			fog2.show()
			fog3.hide()
		3:
			fog1.show()
			fog2.show()
			fog3.show()
		_: return

class FogSetup:
	var color: Color
	var density: float
	var period: int
	var shift: Vector2
	
	func _init(col, den, per, shif):
		color = col
		density = den
		period = per
		shift = shif
