extends MarginContainer

onready var descriptionLabel = find_node("DescriptionLabel")
onready var itemPicture = find_node("ItemPicture")

func _ready():
	hide()

func Activate(item: Item):
	var info = item.GetInformation()
	var text = ""
	for i in info:
		text += RefactorInBbCode(i) + "\n"
	descriptionLabel.append_bbcode(text)
	itemPicture.texture = item.inventoryTexture
	show()

func Deactivate():
	hide()
	descriptionLabel.text = ""
	itemPicture.set_deferred("texture", null)

func RefactorInBbCode(s: String) -> String:
	var place = s.find(":")
	var sub = ""
	if(place > 0):
		var bul= s.substr(0, place + 1)
		sub = "[color=blue][b]" + bul + "[/b][/color]"
		s = s.replace(bul, sub)
	return s

func can_drop_data(_position, data):
	return (data.slot != null)

func drop_data(_position, data):
	data.slot.Put(data)

func _on_CloseButton_button_up():
	Deactivate()
