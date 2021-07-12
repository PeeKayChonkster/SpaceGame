extends CanvasLayer


var materialsPath = "res://src/Materials/ParticleMaterials/"

var materials = []


# Called when the node enters the scene tree for the first time.
func _ready():
	LoadMaterials(materialsPath)
	for material in materials:
		var particleSystem = Particles2D.new()
		particleSystem.process_material = material
		particleSystem.one_shot = true
		particleSystem.modulate = Color(1.0, 1.0, 1.0, 0.0)
		particleSystem.emitting = true
		self.add_child(particleSystem)


func LoadMaterials(path):
	var dir = Directory.new()
	if (dir.dir_exists(path)):
		dir.change_dir(path)
		dir.list_dir_begin(true)
		while(true):
			var nextName: String = dir.get_next()
			if (nextName == ""): break
			if(dir.current_is_dir()):
				LoadMaterials(path + nextName + "/")
				continue
			var filePath = path + nextName
			var newItem = ResourceLoader.load(filePath)
			materials.append(newItem)
		dir.list_dir_end()
