extends Panel

onready var progressBar = $ProgressBar

func _ready():
	hide()

func Activate():
	show()

func Deactivate():
	progressBar.value = 0
	hide()

func SetProgressPercent(value: int):
	progressBar.value = value
