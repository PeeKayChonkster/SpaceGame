extends Panel

onready var nameLabel = $NinePatchRect/NameLabel
onready var http = $HTTPRequest
onready var newsTextLabel = $NinePatchRect/TabContainer/News/MarginContainer/NewsTextLabel

var planet


func _ready():
	hide()
	pause_mode = Node.PAUSE_MODE_PROCESS
	planet = get_parent()
	nameLabel.text = planet.name

func Activate():
	planet.remove_child(self)
	GameController.ui.add_child(self)
	GetNews()
	show()

func Deactivate():
	GameController.ui.remove_child(self)
	planet.add_child(self)
	newsTextLabel.text = "Loading..."    ### delete later
	hide()

func GetNews():
	var query = MapManager.randomQueries[GameController.rng.randi_range(0, GameController.randomQueries.size() - 1)]
	var data = {'filter': 0, 'intro': 0, 'query': query}
	var headers = ["Content-Type: application/json", 'Origin: https://yandex.ru', 'Referer: https://yandex.ru/']
	var dataJSONString = JSON.print(data)
	http.request("https://yandex.ru/lab/api/yalm/text3", headers, true, HTTPClient.METHOD_POST, dataJSONString)

func _on_TakeoffButton_button_up():
	Deactivate()
	GameController.player.TakeOff(planet)


func _on_HTTPRequest_request_completed(result, response_code, _headers, body: PoolByteArray):
	if(result == HTTPRequest.RESULT_SUCCESS && response_code == 200):
		if(!visible): return
		var jsonData = JSON.parse(body.get_string_from_utf8())
		var data: String = jsonData.result.query + jsonData.result.text
		var dataArray = data.split("\n")
		newsTextLabel.text = "    "
		for line in dataArray:
			newsTextLabel.text += " " + line
	else:
		newsTextLabel.text = "Check internet connection"
