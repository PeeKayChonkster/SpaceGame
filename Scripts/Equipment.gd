extends Item
class_name Equipment

var ship
var equipped: bool = false
var originalScale;

func Equip():
	if (!equipped):
		ship = find_parent("Ship_*")
		sprite.hide()
		equipped = true
		interactable = false
		originalScale = scale
		transform = Transform2D()

func Unequip():
	if(equipped):
		ship = null
		interactable = true
		equipped = false
		scale = originalScale
		sprite.show()
