extends Node2D


func LongestVector2(vec1: Vector2, vec2: Vector2) -> Vector2:
	if (vec1.length() > vec2.length()): return vec1
	else: return vec2

func ShortestVector2(vec1: Vector2, vec2: Vector2) -> Vector2:
	if (vec1.length() > vec2.length()): return vec2
	else: return vec1

func RandomVec(fRange: float):
	return Vector2(GameController.rng.randf_range(-fRange, fRange), GameController.rng.randf_range(-fRange, fRange))

func LerpVec2(vec1:Vector2, vec2: Vector2, weigth: float):
	return lerp(vec1, vec2, weigth);

func CreateTimer(time: float, parent = self) -> Timer:
	var timer = Timer.new()
	parent.add_child(timer)
	timer.one_shot = true
	timer.wait_time = time
	timer.connect("timeout", timer, "queue_free")
	timer.start()
	return timer

func Swap(obj1, obj2):
	var temp = obj1
	obj1 = obj2
	obj2 = temp
