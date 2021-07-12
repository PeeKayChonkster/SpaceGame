extends TextureRect


onready var minimap = get_parent().get_parent()

func _process(_delta):
	update()

func DrawPlanetOrbits():
	var star
	for i in minimap.items:
		if i.itemRef is Star:
			star = i
			break
	if (!star): return
	var center = star.icon.position
	for i in minimap.items:
		if(!(i.itemRef is Planet)): continue
		var radius = (i.icon.position - star.icon.position).length()
		draw_arc(center, radius, 0.0, 2.0 * PI, 50, i.itemRef.minimapColor - Color(0.0, 0.0, 0.0, 0.3), 1.0, true)

func _draw():
	if (!minimap.items.empty()):
		DrawPlanetOrbits()
