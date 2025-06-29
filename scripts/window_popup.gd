extends Window

@onready var notification_label: Label = $Control/Panel/MarginContainer/VBoxContainer/Label

func _ready():
	# Example: automatically close after a few seconds
	# You might want to remove this if you have a close button
	# Or make it configurable
	var timer = get_tree().create_timer(5.0) # Close after 5 seconds
	timer.timeout.connect(queue_free) # Disconnect if you use a close button only

	# If using borderless, you might want to allow dragging
	# For a simple notification, often you don't need this.
	# set_drag_forwarding(true) # Connect this to input events if you implement drag

func set_message(message_text):
	notification_label.text = message_text

func display(message_text):
	set_message(message_text)
	show() # Show the window
	grab_focus() # Optional: give it focus
	# For transient notifications, you might want to adjust its position
	# relative to the current active screen or mouse cursor.
	# Example (top-right corner):
	# var screen_rect = DisplayServer.screen_get_usable_rect()
	# position = Vector2(screen_rect.size.x - size.x - 20, 20) # 20px padding
