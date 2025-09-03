extends PanelContainer

@onready var reminder_label: Label = $ContantContainer/LabelContainer/ReminderLabel
@onready var repeat_label: Label = $ContantContainer/LabelContainer/RepeatLabel
@onready var edit_texture_button: TextureButton = $ContantContainer/ButtonsContainer/EditTextureButton
@onready var toggle_texture_button: TextureButton = $ContantContainer/ButtonsContainer/ToggleTextureButton
@onready var delete_texture_button: TextureButton = $ContantContainer/ButtonsContainer/DeleteTextureButton

var unix_time: int
var repeat_time: int = 0
var active := true

func _ready() -> void:
	delete_texture_button.pressed.connect(_on_delete_button_pressed)
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
		
		reminder_label.text = weekday + " ב " + date_parts["hour"] + ":" + date_parts["minutes"]


func _on_delete_button_pressed() -> void:
	queue_free()
