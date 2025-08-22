class_name QuestionWidget
extends VBoxContainer

@onready var question_label: Label = $HBoxContainer/QuestionLabel
@onready var mandatory_label: Label = $HBoxContainer/MandatoryLabel
@onready var answer_text_edit: CycledPlaceholderTextEdit = $AnswerTextEdit

@export var question_massage: String: set = _set_question_massage
@export var place_holder_massage: String: set = _set_place_holder_answer
@export var mandatory := false

func _set_question_massage(value: String) -> void:
	question_massage = value
	change_question_massage(question_massage)


func _set_place_holder_answer(value: String) -> void:
	place_holder_massage = value
	change_place_holder_massage(place_holder_massage)


func _ready() -> void:
	mandatory_label.visible = mandatory
	change_question_massage(question_massage)
	change_place_holder_massage(place_holder_massage)


func change_question_massage(new_massage: String) -> void:
	if new_massage && question_label:
		question_label.text = question_massage


func change_place_holder_massage(new_place_holder_answer) -> void:
	if new_place_holder_answer and answer_text_edit:
		answer_text_edit.placeholder_text = place_holder_massage


func get_answer() -> String:
	return answer_text_edit.text
