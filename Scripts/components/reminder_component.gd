extends PanelContainer

@onready var reminder_label: Label = $ContantContainer/LabelContainer/ReminderLabel
@onready var time_label: Label = $ContantContainer/LabelContainer/TimeLabel
@onready var edit_texture_button: TextureButton = $ContantContainer/ButtonsContainer/EditTextureButton
@onready var edit_name_texture_button: TextureButton = $ContantContainer/ButtonsContainer/EditNameTextureButton
@onready var delete_texture_button: TextureButton = $ContantContainer/ButtonsContainer/DeleteTextureButton
@onready var calendar_canvas_layer: CanvasLayer = $CalendarCanvasLayer
@onready var calendar_component: Panel = $CalendarCanvasLayer/CalendarComponent
@onready var label_container: VBoxContainer = $ContantContainer/LabelContainer
@onready var reminder_line_edit: LineEdit = $ContantContainer/ReminderLineEdit
@onready var buttons_container: HBoxContainer = $ContantContainer/ButtonsContainer
@onready var save_button: Button = $ContantContainer/SaveButton

var reminder_name: String :
	set(new_value):
		reminder_name = new_value
		# TODO update labels
var unix_time: int :
	set(new_value):
		unix_time = new_value
		if is_node_ready():
			update_reminder_label()
	
	get(): return unix_time
var repeat_time: int = 0
var active := true

func _ready() -> void:
	delete_texture_button.pressed.connect(_on_delete_button_pressed)
	edit_texture_button.pressed.connect(_on_edit_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	edit_name_texture_button.pressed.connect(_on_edit_name_button_pressed)
	calendar_component.DateSelected.connect(_on_calendar_coponent_date_selected)
	calendar_component.Cancel.connect(_on_calendar_component_cancel)
	update_reminder_label()


func update_reminder_label():
	if unix_time:
		var date_parts = HebrewDateConverter.GetDatePartsFromUnix(unix_time, true)
		var weekday = date_parts["weekday"]
		
		if Time.get_datetime_dict_from_unix_time(unix_time)["year"] == Time.get_datetime_dict_from_system()["year"] \
		&& Time.get_datetime_dict_from_unix_time(unix_time)["month"] == Time.get_datetime_dict_from_system()["month"]:
			if Time.get_datetime_dict_from_unix_time(unix_time)["day"] == Time.get_datetime_dict_from_system()["day"]:
				weekday = "היום"
			elif Time.get_datetime_dict_from_unix_time(unix_time)["day"] == Time.get_datetime_dict_from_system()["day"] + 1:
				weekday = "מחר"
		
		time_label.text = weekday + " ב " + date_parts["hour"] + ":" + date_parts["minutes"]


func _on_delete_button_pressed() -> void:
	queue_free()


func _on_edit_button_pressed() -> void:
	calendar_canvas_layer.show()


func _on_calendar_coponent_date_selected(unix: int) -> void:
	unix_time = unix
	calendar_canvas_layer.hide()


func _on_calendar_component_cancel() -> void:
	calendar_canvas_layer.hide()


func _on_edit_name_button_pressed() -> void:
	label_container.hide()
	buttons_container.hide()
	reminder_line_edit.text = reminder_label.text
	reminder_line_edit.show()
	save_button.show()


func _on_save_button_pressed() -> void:
	reminder_label.text = reminder_line_edit.text
	label_container.show()
	buttons_container.show()
	reminder_line_edit.hide()
	save_button.hide()
