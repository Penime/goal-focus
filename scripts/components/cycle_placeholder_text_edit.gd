class_name CycledPlaceholderTextEdit
extends TextEdit

@onready var placeholder_interval_timer: Timer = $PlaceholderIntervalTimer

@export_range(1, 10) var cycle_interval_time: float = 2.5
@export_range(0.5, 2) var fade_duration: float = 0.5
@export var placeholder_cycled_text: Array[String]

var current_index: int = 0


func _ready() -> void:
	placeholder_cycled_text.shuffle()
	if placeholder_cycled_text.size() > 0:
		placeholder_text = placeholder_cycled_text[current_index]
		placeholder_interval_timer.timeout.connect(_on_timer_timeout)
		placeholder_interval_timer.start(cycle_interval_time)


func cycle_placeholder_text() -> void:
	current_index = (current_index + 1) % len(placeholder_cycled_text)
	placeholder_text = placeholder_cycled_text[current_index]
	_fade_placeholder(fade_duration, Color.from_rgba8(179, 134, 92))
	placeholder_interval_timer.start(cycle_interval_time)


func _on_timer_timeout() -> void:
	await _fade_placeholder(fade_duration, Color.TRANSPARENT).finished
	cycle_placeholder_text()


func _fade_placeholder(duration: float, target_color: Color) -> Tween:
	var placeholder_color_tween = create_tween()
	placeholder_color_tween.tween_property(self, "theme_override_colors/font_placeholder_color", target_color, duration)
	placeholder_color_tween.play()
	return placeholder_color_tween
