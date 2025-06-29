extends Page

@onready var start_form_button: Button = $ContentContainer/StartFormButton


func _ready() -> void:
	start_form_button.pressed.connect(_on_start_form_button_pressed)


func _on_start_form_button_pressed() -> void:
	change_page_to(GlobalData.GOAL_FORM_PAGE, "animate_in_from_down", "animate_out")
