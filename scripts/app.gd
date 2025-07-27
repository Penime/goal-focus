extends Control

@onready var pages: Control = $MarginContainer/Page

const INITIAL_PAGE = preload("res://scenes/pages/start_form_page.tscn")


func _ready() -> void:
	var starting_page : Page = INITIAL_PAGE.instantiate()
	pages.add_child(starting_page)


func _on_page_child_entered_tree(_node: Node) -> void:
	var pages = %Page
	if pages.get_child_count() > 2:
		$MarginContainer/Page.get_child(0).queue_free()
