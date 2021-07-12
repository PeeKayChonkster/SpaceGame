extends Node2D
class_name Planet



onready var sprite = $Sprite
onready var planetUI = $PlanetUI
onready var interactionArea = $Area2D
onready var ring = $Ring

var radius: float
var orbitStar : Star
var orbitRadius: float
var orbitSpeed: float
var maxRotationSpeed: float = 0.03

### minimap stuff
onready var minimapIcon = "planet"
var minimapColor = Color.white   ### minimap color

var planetInfo: PlanetInfo

func _ready():
	SetRadius(radius)

func SetRadius(value: float):
	radius = value
	if(sprite):
		var unit = 1.0 / 250.0
		scale = Vector2(unit * radius, unit * radius)

func SetColor(col: Color):
	sprite.material.set_shader_param("color", col)

func SetSeed(col: Color):
	sprite.material.set_shader_param("seed", col)

func SetRotation(value: Vector2):
	sprite.material.set_shader_param("xRotation", value.x)
	sprite.material.set_shader_param("yRotation", value.y)

func SetBrightness(value: float):
	value = clamp(value, 0.0, 1.0);
	sprite.material.set_shader_param("brightness", value)

func SetWaterColor(col: Color):
	sprite.material.set_shader_param("waterColor", col)
	minimapColor = col

func SetLandColor(col: Color):
	sprite.material.set_shader_param("landColor", col)

func SetAtmoColor(col: Color):
	sprite.material.set_shader_param("atmoColor", col)

func SetRingColor(col: Color):
	var darkner = Color(0.3, 0.3, 0.3, 0.0)
	ring.modulate = col - darkner

func SetRingAngle(angle: float):
	rotation = angle

func SetWaterLevel(value: float):
	value = clamp(value, 0.0, 1.0)
	sprite.material.set_shader_param("waterLevel", value)

func SetAtmoLevel(_value: float):
	#value = clamp(value, 0.55, 0.55)
	sprite.material.set_shader_param("atmoLevel", 0.55)

func SetOrbit(star:Star, rad: float, speed: float):
	orbitStar = star
	orbitRadius = rad
	orbitSpeed = speed

func SetSurface(info: PlanetInfo):
	info.noiseTexture.noise = info.noise
	info.noiseTexture.seamless = true
	info.noiseAtmoTexture.noise = info.atmoNoise
	info.noiseAtmoTexture.seamless = true
	sprite.material.set_shader_param("noise", info.noiseTexture)   ### slow as fuck?
	sprite.material.set_shader_param("atmoNoise", info.noiseAtmoTexture)   ### slow as fuck?
	SetColor(info.minimapColor)
	SetWaterColor(info.waterColor);
	SetLandColor(info.landColor);
	SetAtmoColor(info.atmoColor);
	if(info.ring):
		ring.show()
		SetRingColor(info.ringColor)
		SetRingAngle(info.ringAngle)
	SetRotation(info.rotation)
	SetWaterLevel(info.waterLevel)
	SetAtmoLevel(info.atmoLevel);
	planetInfo = info

func SetRandomSurface():
	#surface
	# period 30 .. 256
	# lacunarity 0.1 .. 4.0
	# persistence 0.0 .. 1.0
	# seed any int
	
	# atmosphere
	# period 50 .. 200
	# lacunarity 2.0 .. 4.0
	# persistence 0.5 .. 1.0
	# seed any int
	var rng = GameController.rng
	
	var info = PlanetInfo.new()
	
	info.name = name
	
	var newNoise = OpenSimplexNoise.new()
	newNoise.seed = rng.randi()
	newNoise.octaves = 3
	newNoise.period = rng.randi() % 256 + 30
	newNoise.persistence = rng.randf()
	newNoise.lacunarity = rng.randf_range(0.1, 4.0)
	info.noise = newNoise
	
	var newAtmoNoise = OpenSimplexNoise.new()
	newNoise.seed = rng.randi()
	newAtmoNoise.octaves = 3
	newAtmoNoise.period = rng.randi() % 200 + 50
	newAtmoNoise.persistence = rng.randf_range(0.5, 1.0)
	newAtmoNoise.lacunarity = rng.randf_range(2.0, 4.0)
	info.atmoNoise = newAtmoNoise
	
	var newTexture = NoiseTexture.new()
	var newAtmoTexture = NoiseTexture.new()
	newTexture.noise = newNoise
	newTexture.seamless = true
	newAtmoTexture.noise = newAtmoNoise
	newAtmoTexture.seamless = true
	info.waterColor = Color(rng.randf(), rng.randf(), rng.randf(), 1.0)
	info.minimapColor = info.waterColor
	info.landColor = Color(rng.randf(), rng.randf(), rng.randf(), 1.0)
	info.atmoColor = Color(rng.randf(), rng.randf(), rng.randf(), 1.0)
	info.ring = rng.randf() > 0.9
	info.ringColor = Color(rng.randf(), rng.randf(), rng.randf(), rng.randf_range(0.3, 1.0))
	info.ringAngle = rng.randf() * 2.0 * PI
	info.rotation = Vector2(rng.randf_range(-maxRotationSpeed, maxRotationSpeed), rng.randf_range(-maxRotationSpeed, maxRotationSpeed))
	info.waterLevel = rng.randf_range(0.3, 0.8)
	info.atmoLevel = 0.55
	info.noiseTexture = newTexture
	info.noiseAtmoTexture = newAtmoTexture
	planetInfo = info
	SetSurface(info)

func Interact(who):
	who.Land(self)

func ActivateUI():
	planetUI.Activate()

func DeactivateUI():
	planetUI.Deactivate()

func GetInfo() -> PlanetInfo:
	planetInfo.position = global_position
	planetInfo.orbitRadius = orbitRadius
	planetInfo.orbitSpeed = orbitSpeed
	planetInfo.radius = radius
	return planetInfo

func _on_Area2D_body_entered(body):
	if ("pilot" in body && body.pilot):
		body.pilot.OfferInteraction(self, "Land")

func _on_Area2D_body_exited(body):
	if ("pilot" in body && body.pilot):
		body.pilot.DenyInteraction()

class PlanetInfo:
	var name
	var position: Vector2
	var radius: float
	var orbitRadius: float
	var orbitSpeed: float
	var minimapColor
	var noise
	var atmoNoise
	var noiseTexture
	var noiseAtmoTexture
	var landColor
	var waterColor
	var atmoColor
	var rotation: Vector2
	var ring: bool
	var ringColor
	var ringAngle
	var waterLevel
	var atmoLevel
