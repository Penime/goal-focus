extends Page

@onready var back_button: Button = $ContentContainer/Buttons/BackButton
@onready var next_button: Button = $ContentContainer/Buttons/NextButton
@onready var question: QuestionWidget = $ContentContainer/Question


func _ready() -> void:
	if GlobalData.procss_data.has("goal") && GlobalData.procss_data["goal"].goal_massage:
		question.answer_text_edit.text = GlobalData.procss_data["goal"].goal_massage
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)


func _on_next_button_pressed() -> void:
	if question.get_answer():
		GlobalData.procss_data["goal"] = Goal.new(question.get_answer())
		change_page_to(GlobalData.MEAN_FORM_PAGE, "animate_in_from_left", "animate_out")
	else: GlobalData.show_notification("זהו שדה חובה!", 2)


func _on_back_button_pressed() -> void:
	change_page_to(GlobalData.STARTING_PAGE, "animate_in_from_right", "animate_out")
