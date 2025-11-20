extends PanelContainer

var goal: Goal:
	set(new_goal):
		goal = new_goal
		if ready:
			_update_elements()

@onready var done_good_button: TextureButton = $HBoxContainer/SummeryContainer/DoneGoodButton
@onready var doe_better_button: TextureButton = $HBoxContainer/SummeryContainer/DoeBetterButton
@onready var goal_title_label: Label = $HBoxContainer/LabelsContainer/GoalTitleLabel
@onready var goal_mean_label: Label = $HBoxContainer/LabelsContainer/GoalMeanLabel
@onready var reminders_container: HBoxContainer = $HBoxContainer/RemindersContainer
@onready var reminder_label: Label = $HBoxContainer/RemindersContainer/ReminderLabel


func _ready() -> void:
	done_good_button.pressed.connect(_on_done_good_button_pressed)
	doe_better_button.pressed.connect(_on_doe_better_button_pressed)
	reminders_container.gui_input.connect(_on_reminders_container_gui_input)
	_update_elements()


func _update_elements():
	if not goal: return
	goal_title_label.text = goal.title
	goal_mean_label.text = goal.mean

	var reminders: Array[GoalReminder] = Database.get_reminders_by_goal_id(goal.id)
	var closest_reminder_time = 0
	for reminder in reminders:
		if reminder.time > closest_reminder_time:
			closest_reminder_time = reminder.time
	
	var date_parts = HebrewDateConverter.GetDatePartsFromUnix(closest_reminder_time, true)
	reminder_label.text = str(date_parts["hour"]) + ":" + str(date_parts["minute"])


func _on_done_good_button_pressed() -> void:
	pass


func _on_doe_better_button_pressed() -> void:
	pass


func _on_reminders_container_gui_input(even: InputEvent) -> void:
	pass
