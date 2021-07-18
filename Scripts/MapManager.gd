extends Node

onready var starPrefab = preload("res://Scenes/CosmicBodies/Star.tscn")
onready var planetPrefab = preload("res://Scenes/CosmicBodies/Planet.tscn")
onready var starSystemPrefab = preload("res://Scenes/CosmicBodies/StarSystem.tscn")
onready var stargatePrefab = preload("res://Scenes/CosmicBodies/Stargate.tscn")
onready var thread = Thread.new()

var proceduralSpaceBackground
var cosmicBodies
var ships
var minNumberOfPlanets: int = 1
var maxNumberOfPlanets: int = 8
var minRadiusOfPlanets: float = 100.0
var maxRadiusOfPlanets: float = 400.0
var minRadiusOfStars: float = 700.0
var maxRadiusOfStars: float = 1200.0
var minNumberOfStargates: int = 1
var maxNumberOfStargates: int = 4
var currentSystem: int
var systemsInfo = []


#### delete later!!!
var randomQueries = [
	"На этой планете",
	"Эта планета",
	"В этом маленьком мире",
	"Не смотря на то, что эта планета",
	"Природа здесь",
	"Каменные равнины и холодный климат",
	"Кислотные дожди ежедневно",
	"Население этой планеты",
	"Каждый день на этой небольшой планете",
	"Жизнь на этой планете",
	"Экономика этой планеты",
]


func _ready():
	Initialize()

func SpawnPlanet(info, parent = cosmicBodies) -> Planet:
	var newPlanet = planetPrefab.instance() as Planet
	assert(cosmicBodies)
	parent.add_child(newPlanet, true)
	newPlanet.set_name(info.name)
	newPlanet.SetSurface(info)
	newPlanet.SetRadius(info.radius)
	newPlanet.global_position = info.position
	newPlanet.planetInfo = info
	#GameController.ui.AppendMinimap(newPlanet)
	return newPlanet

func SpawnRandomPlanet(coord: Vector2, parent = cosmicBodies) -> Planet:
	var newPlanet = planetPrefab.instance() as Planet
	assert(cosmicBodies)
	parent.add_child(newPlanet, true)
	newPlanet.SetRandomSurface()
	newPlanet.SetRadius(GameController.rng.randf_range(minRadiusOfPlanets, maxRadiusOfPlanets))
	newPlanet.global_position = coord
	#GameController.ui.AppendMinimap(newPlanet)
	return newPlanet

func SpawnStar(info, parent = cosmicBodies) -> Star:
	var newStar = starPrefab.instance() as Star
	assert(cosmicBodies)
	parent.add_child(newStar, true)
	newStar.set_name(info.name)
	newStar.SetSurface(info)
	newStar.SetRadius(info.radius)
	newStar.global_position = info.position
	newStar.starInfo = info
	#GameController.ui.AppendMinimap(newStar)
	return newStar

func SpawnRandomStar(coord: Vector2, parent = cosmicBodies) -> Star:
	var newStar = starPrefab.instance() as Star
	assert(cosmicBodies)
	parent.add_child(newStar, true)
	newStar.SetRandomSurface()
	newStar.SetRadius(GameController.rng.randf_range(minRadiusOfStars, maxRadiusOfStars))
	newStar.global_position = coord
	#GameController.ui.AppendMinimap(newStar)
	return newStar

func SpawnStargate(info, parent = cosmicBodies):
	var newGate = stargatePrefab.instance()
	assert(cosmicBodies)
	parent.add_child(newGate, true)
	newGate.set_name(info.name)
	newGate.global_position = info.position
	newGate.destinationSystemID = info.destinationSystemID
	#GameController.ui.AppendMinimap(newGate)
	return newGate

func SpawnRandomStargate(coord: Vector2, parent = cosmicBodies):
	var newGate = stargatePrefab.instance()
	assert(cosmicBodies)
	newGate.global_position = coord
	parent.add_child(newGate, true)
	#GameController.ui.AppendMinimap(newGate)
	return newGate

func SpawnStarSystem(stargate) -> StarSystem:
	assert(cosmicBodies)
	var newStarSystem = starSystemPrefab.instance()
	
	# Get info on old and new systems from MapManager
	var oldSystemInfo = GetSystemInfo(stargate.GetInfo().currentSystemID)
	var newSystemInfo = GetSystemInfo(stargate.GetInfo().destinationSystemID)
	
	# spawn star
	cosmicBodies.add_child(newStarSystem, true)
	newStarSystem.star = SpawnStar(newSystemInfo.star, newStarSystem)
	
	# spawn planets
	for p in newSystemInfo.planets:
		var newPlanet = SpawnPlanet(p, newStarSystem)
		newStarSystem.planets.append(newPlanet)
	newStarSystem.global_position = newSystemInfo.position
	newStarSystem.GenerateOrder(newSystemInfo)
	
	# spawn stargates
	for s in newSystemInfo.stargates:
		var newStargate = SpawnStargate(s, newStarSystem)
		newStarSystem.stargates.append(newStargate)
		# move player to the stargate which is connected to previous starsystem
		if (oldSystemInfo.id == s.destinationSystemID):
			GameController.player.Move(s.position)
	
	# give systemInfo to the new stargates after all system is generated (including new stargates)
	for s in newStarSystem.stargates:
		s.currentSystemID = newStarSystem.GetInfo().id
	
	proceduralSpaceBackground.GenerateFogColor(newStarSystem.GetInfo().id)
	
	return newStarSystem

func SpawnRandomStarSystem(coord: Vector2, entryStargate = null) -> StarSystem:
	assert(cosmicBodies)
	var newStarSystem = starSystemPrefab.instance()
	
	# spawn random star
	cosmicBodies.add_child(newStarSystem)
	newStarSystem.star = SpawnRandomStar(Vector2.ZERO, newStarSystem)
	
	# spawn random planets
	var numberOfPlanets = GameController.rng.randi() % maxNumberOfPlanets + minNumberOfPlanets
	for _i in range(numberOfPlanets):
		var newPlanet = SpawnRandomPlanet(Vector2.ZERO, newStarSystem)
		newStarSystem.planets.append(newPlanet)
	newStarSystem.global_position = coord
	newStarSystem.GenerateRandomOrder()
	
	# randomly generate number of new stargates and calculate their orbit radius
	var stargateOrbitRadius = newStarSystem.planets.back().orbitRadius + newStarSystem.planets.back().radius + 1000.0
	var numberOfStargates = GameController.rng.randi_range(minNumberOfStargates, maxNumberOfStargates)
	
	# if player travelled to the new system through a stargate, create new stargate, 
	# positioned accordingly to the old one
	if(entryStargate): 
		if(numberOfStargates > 1): numberOfStargates -= 1
		var newStargatePosition = entryStargate.GetInfo().position.normalized() * stargateOrbitRadius * -1.0
		var newStargate = SpawnRandomStargate(newStargatePosition, newStarSystem)
		newStarSystem.stargates.append(newStargate)
		# link this new stargate to the old system
		newStargate.destinationSystemID = entryStargate.currentSystemID
		GameController.player.Move(newStargatePosition)
	
	# create newSystem stargates
	var angle
	if(entryStargate):
		angle = entryStargate.global_position.angle() + PI
	else:
		angle = GameController.rng.randf_range(0.0, 2.0 * PI)
	for _i in range(numberOfStargates):
		var newStargate = SpawnRandomStargate((Vector2.DOWN * stargateOrbitRadius).rotated(angle), newStarSystem)
		newStarSystem.stargates.append(newStargate)
		angle += GameController.rng.randf_range(deg2rad(30), deg2rad(80))
	
	# give currentSystemID to the new stargates after all system is generated (including new stargates)
	for s in newStarSystem.stargates:
		s.currentSystemID = newStarSystem.GetInfo().id
	
	# give info about new system to the MapManager
	systemsInfo.append(newStarSystem.GetInfo())
	
	if(entryStargate): 
		# set old stargate destinationSystemID inside the MapManager array
		ChangeStargateDestinationID(entryStargate.currentSystemID, entryStargate, newStarSystem.GetInfo().id)
		# set old stargate destinationSystemID
		entryStargate.destinationSystemID = newStarSystem.GetInfo().id
	
	proceduralSpaceBackground.GenerateFogColor(newStarSystem.GetInfo().id)
	
	return newStarSystem

func ClearAllCosmicBodies():
	var children = cosmicBodies.get_children()
	GameController.ui.ClearMinimap()
	for c in children:
		c.queue_free()

func GetSystemInfo(id: float):
	for s in systemsInfo:
		if (s.id == id): return s

### Set stargate destinationID (Needed when traveling to a new system to set old stargate
### destination system link to the new system)
func ChangeStargateDestinationID(systemID: float, stargate, value):
	var starSystemInfo = GetSystemInfo(systemID)
	var stargateInfo
	for s in starSystemInfo.stargates:
		if (s.id == stargate.GetInfo().id):
			stargateInfo = s
			break
	if (!stargateInfo): printerr("Can't find stargate with the given id. Probably problem with stargate hashes.")
	stargateInfo.set("destinationSystemID", value)

func Initialize():
	while(!GameController.initialized): yield(get_tree(), "idle_frame")
	cosmicBodies = GameController.world.get_node("CosmicBodies")
	proceduralSpaceBackground = GameController.world.get_node("ProceduralSpaceBackground")
