class_name ReminderPage
extends Page

@onready var back_button: Button = $VBoxContainer/Buttons/BackButton
@onready var next_button: Button = $VBoxContainer/Buttons/NextButton
@onready var add_reminder_button: MenuButton = $VBoxContainer/AddReminderButton
@onready var reminders_container: VBoxContainer = $VBoxContainer/RemindersContainer
@onready var create_reminder_canvas_layer: CanvasLayer = $CreateReminderCanvasLayer
@onready var calendar_component: Panel = $CreateReminderCanvasLayer/MarginContainer/CalendarComponent


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	add_reminder_button.get_popup().id_pressed.connect(_on_button_menu_id_pressed)
	calendar_component.DateSelected.connect(_on_date_selected)
	calendar_component.Cancel.connect(_on_calendar_cancel)


func _on_back_button_pressed() -> void:
	change_page_to(GlobalData.MEAN_FORM_PAGE, "animate_in_from_right", "animate_out")


func _on_next_button_pressed() -> void:
	pass


func _on_date_selected(unix: int) -> void:
	var reminder_instance = GlobalData.REMINDER_COMPONENT.instantiate()
	reminder_instance.unix_time = unix
	reminders_container.add_child(reminder_instance)
	create_reminder_canvas_layer.hide()


func _on_calendar_cancel() -> void:
	create_reminder_canvas_layer.hide()


func _on_button_menu_id_pressed(id: int) -> void:
	var reminder_instance = GlobalData.REMINDER_COMPONENT.instantiate()
	
	match id:
		0:
			# get time the long way to avoid utc shift
			reminder_instance.unix_time = int(Time.get_unix_time_from_datetime_string(Time.get_datetime_string_from_system())) + 60 *  30
		1:
			reminder_instance.unix_time = int(Time.get_unix_time_from_datetime_string(Time.get_datetime_string_from_system())) + 60 *  60
		2:
			create_reminder_canvas_layer.show()
	
	if id != 2:
		reminders_container.add_child(reminder_instance)
