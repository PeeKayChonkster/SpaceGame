extends Camera2D


export (NodePath) var followTarget
export (float) var smoothness = 1.0
export (float) var dynamicMinZoom = 0.5
export (float) var dynamicMaxZoom = 1.3
export (float, 0.0, 2.0) var dynamicZoomSpeed
export (bool) var follow = false
export (bool) var dynamic = true
export (bool) var progressive = true
export (float) var progressiveCursorComponent = 3.0
export (float) var progressiveVelocityComponent = 3.0

var target
var initialOffset:Vector2
var dynamicZoomRatio = 0.0

func _ready():
	if (!target):
		if(followTarget):
			target = get_node(followTarget)
		else:
			target = get_parent()
	initialOffset = global_position - target.global_position
	global_position = target.global_position + initialOffset
	# turn off progressive mode if target doesn't have velocity
	if(!"velocity" in target): progressive = false
	set_as_toplevel(true)
	current = true


func _process(delta):
	if(follow && target):
		if(!progressive):
			global_position = lerp(global_position, target.global_position + initialOffset, ( 1.0 / smoothness) * delta)
		elif(target.moveCursor):
			global_position = lerp(global_position, target.global_position + initialOffset +  target.moveCursor.rect_position * progressiveCursorComponent * 0.1 + target.velocity * progressiveVelocityComponent * 0.1, ( 1.0 / smoothness) * delta)
		if(dynamic):
			var zoom1 = lerp(Vector2(dynamicMinZoom, dynamicMinZoom), Vector2(dynamicMaxZoom, dynamicMaxZoom), dynamicZoomRatio * dynamicZoomSpeed)
			zoom = lerp(zoom, zoom1, dynamicZoomSpeed * delta)

func SetDynamicZoomRatio(value: float):
	dynamicZoomRatio = clamp(value, 0.0, 1.0)
