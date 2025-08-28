class_name Notification
extends PanelContainer

@export var text: String
@export_range(0.001, 10.0) var duration: float = 1

@onready var timer: Timer = $Timer
@onready var text_label: Label = $HBoxContainer/MarginContainer/TextLabel
@onready var fade_animation_component: FadeAnimationComponent = $FadeAnimationComponent


func _ready() -> void:
	fade_animation_component.target_node = self
	timer.wait_time = duration
	text_label.text = text
	timer.timeout.connect(_on_timer_timeout)
	position.y = -(size.y + 10)
	timer.start()
	fade_animation_component.animate_in_from_up()


func _on_timer_timeout() -> void:
	fade_animation_component.animate_out()
	await fade_animation_component.animation_ended
	queue_free()
