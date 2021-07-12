extends MarginContainer

export (float) var zoom = 0.1
export (bool) var clip = true

onready var background = $MarginContainer/Background
onready var playerMarker = $MarginContainer/Background/PlayerMarker
onready var planetMarker = $MarginContainer/Background/PlanetMarker
onready var starMarker = $MarginContainer/Background/StarMarker
onready var stargateMarker = $MarginContainer/Background/StargateMarker
onready var iconsSwitch = { "planet" : planetMarker, "star" : starMarker, "stargate" : stargateMarker }

var player
var scale
var initialSize
var initialPosition
var folded = true
var animating = false

var items = []


func _ready():
	var _error = GameController.connect("player_initialized", self, "_Initialize")
	scale = background.rect_size.x / get_viewport_rect().size.x * zoom
	items.clear()
	initialSize = rect_size
	initialPosition = rect_position

func Cycle():
	while(true):
		playerMarker.position = background.rect_size / 2.0
		for i in items:
			var pos = (i.itemRef.global_position - player.global_position) * scale + background.rect_size / 2.0
			if(!clip):
				pos.x = clamp(pos.x, 0.0, background.rect_size.x)
				pos.y = clamp(pos.y, 0.0, background.rect_size.y)
			i.icon.position = pos
		yield(get_tree(), "idle_frame")

func LoadItems():
	Clear()
	var newItems = get_tree().get_nodes_in_group("minimap_objects")
	for i in newItems:
		if "minimapIcon" in i:
			Append(i)

func Clear():
	for i in items:
		i.icon.queue_free()
	items.clear()

func Append(item):
	if "minimapIcon" in item:
		var newIcon = iconsSwitch[item.minimapIcon].duplicate()
		background.add_child_below_node(starMarker ,newIcon)
		newIcon.show()
		if "radius" in item: newIcon.scale = Vector2(item.radius * 0.005 * zoom, item.radius * 0.005 * zoom)
		if "minimapColor" in item: newIcon.modulate = item.minimapColor
		var label = newIcon.get_child(0).get_child(0)
		label.text = item.name
		label.get_parent().scale /= newIcon.scale.x
		items.append(MinimapItem.new(item, newIcon))

func Toggle():
	if (folded): Unfold()
	else: Fold()

func Fold():
	if (!animating):
		animating = true
		folded = true
		# hide labels with names
		for i in items:
			i.icon.get_child(0).hide()
		# 1 is for animation to end faster
		while(rect_size.x > initialSize.x + 1):
			rect_size.x = lerp(rect_size.x, initialSize.x, 0.2)
			rect_size.y = lerp(rect_size.y, initialSize.y, 0.2)
			rect_position.x = lerp(rect_position.x, get_viewport_rect().size.x - initialSize.x, 0.2)
			yield(get_tree(), "idle_frame")
		animating = false

func Unfold():
	if (!animating):
		animating = true
		folded = false
		# 1 is for animation to end faster
		while(rect_size.x < get_viewport_rect().size.x - 1):
			rect_size.x = lerp(rect_size.x, get_viewport_rect().size.x, 0.2)
			rect_size.y = lerp(rect_size.y, get_viewport_rect().size.y, 0.2)
			rect_position.x = lerp(rect_position.x, 0.0, 0.2)
			yield(get_tree(), "idle_frame")
		# show labels with names
		for i in items:
			i.icon.get_child(0).show()
		animating = false

func _Initialize(value):
	player = value
	playerMarker.position = background.rect_size / 2.0
	Cycle()

func _on_MiniMap_gui_input(event):
	if(event is InputEventMouseButton && event.button_index == 1 && event.pressed):
		Toggle()

class MinimapItem:
	var itemRef
	var icon
	
	func _init(it, ic):
		itemRef = it
		icon = ic
