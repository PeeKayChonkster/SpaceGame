extends Node2D
class_name StarSystem

onready var starPrefab = preload("res://Scenes/CosmicBodies/Star.tscn")
onready var planetPrefab = preload("res://Scenes/CosmicBodies/Planet.tscn")

var star: Star
var planets = []
var stargates = []
var minDistanceBetweenOrbits: float = 100.0
var maxDistanceBetweenOrbits: float = 2000.0
var minOrbitSpeed: float = 3.0
var maxOrbitSpeed: float = 15.0


func _process(delta):
	Animate(delta)

func Animate(delta):
	for p in planets:
		var dir = (p.global_position - star.global_position).normalized()
		dir = dir.rotated(-PI/2.0)
		p.position += dir * p.orbitSpeed * delta

func GenerateOrder(info: StarSystemInfo, ageTime: int = 0):
	star.position = info.star.position
	var i = 0
	for p in planets:
		p.SetOrbit(star, info.planets[i].orbitRadius, info.planets[i].orbitSpeed)
		i += 1
	AgeSystem(ageTime)

func GenerateRandomOrder():
	planets.shuffle()
	star.position = Vector2.ZERO
	var prevRad = star.radius
	for p in planets:
		var rad = prevRad + p.radius + GameController.rng.randf_range(minDistanceBetweenOrbits, maxDistanceBetweenOrbits)
		if (p.ring.visible): rad += p.radius
		p.SetOrbit(star, rad, GameController.rng.randf_range(-maxOrbitSpeed, maxOrbitSpeed))
		prevRad = rad + p.radius
		if (p.ring.visible): prevRad += p.radius
	Reset()
	AgeSystem(GameController.rng.randi_range(0, 5000))

func AgeSystem(timeInSec: int):
	for p in planets:
		var distance = timeInSec * p.orbitSpeed
		var angle = distance / p.orbitRadius
		p.position = p.position.rotated(angle)

func Reset():
	for p in planets:
		p.position = Vector2.DOWN * p.orbitRadius

func GetInfo() -> StarSystemInfo:
	var id = 0.0
	var info = StarSystemInfo.new()
	info.name = name
	info.position = global_position
	info.star = star.GetInfo()
	for p in planets:
		info.planets.append(p.GetInfo())
		id += p.radius + p.orbitRadius
	for s in stargates:
		info.stargates.append(s.GetInfo())
		id += s.position.x
	info.id = hash(id)
	return info

class StarSystemInfo:
	var name
	var id: int
	var position: Vector2
	var star
	var planets = []
	var stargates = []
