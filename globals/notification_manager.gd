extends Node

const WINDOW_POPUP = preload("res://scenes/window_popup.tscn")

var active_notifications = [] # Keep track of open notification windows

func show_notification(message_text):
	var notification_window = WINDOW_POPUP.instantiate()
	get_tree().root.add_child(notification_window) # Add it to the root of the scene tree

	notification_window.set_message(message_text)

	var screen_rect = DisplayServer.screen_get_usable_rect()
	var window_size = notification_window.size # Get the actual size of the instantiated window

	var padding = 20 # Pixels from the screen edge

	# Calculate X position for bottom-left (starts from the left edge)
	var x_pos = padding

	# Calculate Y position for bottom-left (starts from the bottom edge, moves up)
	var start_y = screen_rect.size.y - window_size.y - padding

	# Optional: Stack new notifications above existing ones if multiple appear
	# This loop will make new notifications appear higher up from the bottom
	for i in range(active_notifications.size()):
		start_y -= (active_notifications[i].size.y + 10) # 10px spacing between stacked windows

	notification_window.position = Vector2(x_pos, start_y)

	notification_window.position = Vector2(x_pos, start_y)

	notification_window.display(message_text)
	active_notifications.append(notification_window)

	# Connect to the window's close signal to remove it from our list
	notification_window.close_requested.connect(func():
		active_notifications.erase(notification_window)
		notification_window.queue_free()
	)
	# If the window self-destructs via timer, also remove it from list
	# You might need a custom signal from the notification_window.gd if it uses queue_free directly
	# For now, rely on close_requested or manual cleanup.
