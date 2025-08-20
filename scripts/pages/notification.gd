class_name Notification
extends Page

@export var text: String
@export_range(0.001, 10.0) var duration: float = 1

@onready var timer: Timer = $Timer
@onready var label: Label = $HBoxContainer/Text


func _ready() -> void:
	timer.wait_time = duration
	label.text = text
	timer.timeout.connect(_on_timer_timeout)
	position.y = -(size.y + 10)
	timer.start()
	animate_in_from_up()


func _on_timer_timeout() -> void:
	animate_out()
	await animation_ended
	queue_free()
