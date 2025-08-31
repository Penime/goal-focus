class_name TimeSelectorComponent
extends HBoxContainer

@export var minute: int
@export var hour: int

signal time_chaged(hour, minute)

@onready var time_selector_line_edit: TimeSelectorLineEdit = $TimeSelectorLineEdit


func _ready() -> void:
	if time_selector_line_edit.minute:
		minute = int(time_selector_line_edit.minute)
		hour = int(time_selector_line_edit.hour)
		
	time_selector_line_edit.text_submitted.connect(_on_line_edit_time_submited)


func _on_line_edit_time_submited(_new_text: String) -> void:
		minute = int(time_selector_line_edit.minute)
		hour = int(time_selector_line_edit.hour)
		time_chaged.emit(hour, minute)
