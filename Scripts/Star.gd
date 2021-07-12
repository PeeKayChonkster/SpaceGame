extends Node2D
class_name Star



onready var sprite = $Sprite
onready var light = $Light2D
onready var minimapIcon = "star"

### minimap stuff
var radius: float
var minimapColor = Color.white   ### minimap color

var starInfo: StarInfo

func _ready():
	light.range_height = 500.0
	SetRadius(radius)

func SetRadius(value: float):
	radius = value
	var unit = 1.0 / 250.0    #### 250.0 is a 1/2 of a sun texture size in gamespace
	var lightUnit = 30.0 / 250.0  #### 30.0 is just some nice value, derived from looking at things in space
	sprite.scale = Vector2(unit * radius, unit * radius)
	light.texture_scale = lightUnit * value

func SetColor(col: Color):
	sprite.material.set_shader_param("color", col)
	minimapColor = col

func SetRotation(value: Vector2):
	sprite.material.set_shader_param("xRotation", value.x)
	sprite.material.set_shader_param("yRotation", value.y)

func SetBrightness(value: float):
	value = clamp(value, 0.0, 0.8);
	sprite.material.set_shader_param("brightness", value)

func SetSurface(info: StarInfo):
	light.color = info.minimapColor
	SetColor(info.minimapColor)
	SetRotation(info.rotation)
	SetBrightness(info.brightness)

func SetRandomSurface():
	var rng = GameController.rng
	var info = StarInfo.new()
	info.minimapColor =  Color(rng.randf(), rng.randf(), rng.randf())
	info.rotation = Vector2(rng.randf_range(-0.02, 0.02), rng.randf_range(-0.02, 0.02))
	info.brightness = rng.randf_range(1.0, 2.0)
	starInfo = info
	SetSurface(info)

func GetInfo() -> StarInfo:
	starInfo.name = name
	starInfo.position = global_position
	starInfo.radius = radius
	return starInfo

class StarInfo:
	var name
	var position: Vector2
	var radius: float
	var minimapColor: Color
	var rotation: Vector2
	var brightness: float
