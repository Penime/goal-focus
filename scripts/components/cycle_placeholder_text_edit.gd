extends TextEdit

@onready var placeholder_interval_timer: Timer = $PlaceholderIntervalTimer

@export var placeholder_cycled_text: Array[String]

var current_index: int = 0


func _ready() -> void:
	placeholder_cycled_text.shuffle()
	placeholder_text = placeholder_cycled_text[current_index]
	placeholder_interval_timer.timeout.connect(_on_timer_timeout)
	placeholder_interval_timer.start()


func cycle_placeholder_text() -> void:
	current_index = (current_index + 1) % len(placeholder_cycled_text)
	placeholder_text = placeholder_cycled_text[current_index]


func _on_timer_timeout() -> void:
	cycle_placeholder_text()
