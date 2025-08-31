extends HBoxContainer

@export var minute: int
@export var hour: int

signal time_changed(hour, minute)

@onready var time_selector_line_edit: TimeSelectorLineEdit = $TimeSelectorLineEdit


func _ready() -> void:
	if time_selector_line_edit.minute:
		minute = int(time_selector_line_edit.minute)
		hour = int(time_selector_line_edit.hour)
		
	time_selector_line_edit.time_set.connect(_on_line_edit_time_set)


func _on_line_edit_time_set(minute_str: String, hour_str: String) -> void:
	print(hour_str+":"+minute_str)
	self.minute = int(minute_str)
	self.hour = int(hour_str)
	time_changed.emit(hour, minute)
