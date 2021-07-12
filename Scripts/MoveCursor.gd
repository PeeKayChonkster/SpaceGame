extends TextureRect


var player
var initialized = false

func _ready():
	Initialize()

func _process(_delta):
	if initialized:
		handleMoveCursor()

# keep moveCursor transparent if there is no input
func handleMoveCursor():
	if(!player.screenTouch):
		var idlePosition = get_parent().rect_size / 2.0 - rect_size / 2.0
		rect_position = lerp(rect_position, idlePosition, 0.2)
		get_parent().modulate.a = max((rect_position - idlePosition).length() / GameController.maxMoveCursorDist - 0.05, 0.0)

func Initialize():
	while(!GameController.initialized): yield(get_tree(), "idle_frame")
	player = GameController.player
	initialized = true
