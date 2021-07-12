extends NinePatchRect

onready var fuel = $Fuel
onready var tween = Tween.new()
onready var initialRect = fuel.get_rect()

var ship

func _ready():
	add_child(tween)


func SetFuel(value: float, maxValue: float):
	var newSize = (value / maxValue) * initialRect.size.y
	tween.interpolate_property(fuel, "rect_size:y", fuel.rect_size.y, newSize, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.interpolate_property(fuel, "rect_position:y", fuel.rect_position.y, initialRect.size.y - newSize, 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func _OnFuelUpdate():
	SetFuel(ship.fuel, ship.fuelCapacity)
