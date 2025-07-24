class_name TimeSelectButton
extends Button

signal selected(time_text)


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	selected.emit(text)
