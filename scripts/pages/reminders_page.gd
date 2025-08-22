class_name ReminderPage
extends Page

@onready var back_button: Button = $VBoxContainer/Buttons/BackButton
@onready var next_button: Button = $VBoxContainer/Buttons/NextButton
@onready var add_reminder_button: Button = $VBoxContainer/AddReminderButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	add_reminder_button.pressed.connect(_on_add_reminder_pressed)


func _on_back_button_pressed() -> void:
	change_page_to(GlobalData.MEAN_FORM_PAGE, "animate_in_from_right", "animate_out")


func _on_next_button_pressed() -> void:
	pass


func _on_add_reminder_pressed() -> void:
	return
