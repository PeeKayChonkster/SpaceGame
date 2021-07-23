extends Control


onready var slider = find_node("HSlider")
onready var label = find_node("Label")
onready var moneyLabel = find_node("MoneyLabel")

var answerIsReady = false
var cancel = false
var price: int

func Activate(minValue: int, maxValue: int, newPrice: int):
	SetMinValue(minValue)
	SetMaxValue(maxValue)
	price = newPrice
	slider.value = maxValue
	moneyLabel.text = str(maxValue * price)
	show()

func Deactivate():
	answerIsReady = false
	cancel = false
	hide()

func SetMaxValue(value):
	slider.max_value = value

func SetMinValue(value):
	slider.min_value = value

func GetValue() -> int:
	return slider.value

func _on_HSlider_value_changed(value):
	label.text = str(value)
	moneyLabel.text = str(value * price)

func _on_AcceptButton_button_up():
	answerIsReady = true

func _on_CancelButton_button_up():
	cancel = true
