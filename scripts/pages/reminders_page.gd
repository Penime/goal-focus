class_name ReminderPage
extends Page

@onready var back_button: Button = $VBoxContainer/Buttons/BackButton
@onready var next_button: Button = $VBoxContainer/Buttons/NextButton
@onready var add_reminder_button: Button = $VBoxContainer/AddReminderButton
@onready var reminders_v_box_container: VBoxContainer = $VBoxContainer/RemindersVBoxContainer
@onready var create_reminder_canvas_layer: CanvasLayer = $CreateReminderCanvasLayer
@onready var calendar_component: Panel = $CreateReminderCanvasLayer/MarginContainer/CalendarComponent


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	add_reminder_button.pressed.connect(_on_add_reminder_pressed)
	calendar_component.DateSelected.connect(_on_date_selected)
	calendar_component.Cancel.connect(_on_calendar_cancel)


func _on_back_button_pressed() -> void:
	change_page_to(GlobalData.MEAN_FORM_PAGE, "animate_in_from_right", "animate_out")


func _on_next_button_pressed() -> void:
	pass


func _on_add_reminder_pressed() -> void:
	create_reminder_canvas_layer.show()


func _on_date_selected(unix: int) -> void:
	create_reminder_canvas_layer.hide()


func _on_calendar_cancel() -> void:
	create_reminder_canvas_layer.hide()
