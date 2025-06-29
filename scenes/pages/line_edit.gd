extends LineEdit

@onready var my_line_edit: LineEdit = $"."
@onready var result_label: Label = $"../ResultLabel"
@onready var check_button: Button = $"../CheckButton"

func _ready():
	check_button.pressed.connect(_on_check_button_pressed)

func _on_check_button_pressed():
	var text_to_check = my_line_edit.text
	var pattern = "hello*" # Matches "hello", "helloword", etc.

	if text_to_check.match(pattern):
		result_label.text = "Text matches the pattern!"
		result_label.modulate = Color.GREEN # Green for success
	else:
		result_label.text = "Text does not match the pattern."
		result_label.modulate = Color.RED # Red for failure
