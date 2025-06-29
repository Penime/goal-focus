class_name HourSelectorLineEdit
extends LineEdit

var _last_valid_text: String = ""


func _ready() -> void:
	# Set max length to 5 for HH:MM format.
	max_length = 5
	placeholder_text = "HH:MM"
	
	# Connect signals to the validation methods.
	text_changed.connect(_on_text_changed)
	text_submitted.connect(_on_text_submitted)
	focus_exited.connect(_on_focus_exited)

	# Perform an initial validation and formatting of the text property.
	_finalize_input(text)


func _on_text_changed(new_text: String) -> void:
	# This signal is emitted when the text changes, but also when we change it from code.
	# To prevent an infinite loop, we check if the new_text is the same as the last valid one.
	if new_text == _last_valid_text:
		return

	if _is_valid_partial_input(new_text):
		_last_valid_text = new_text
		# A small UX improvement: automatically add the colon after a valid hour is typed.
		if new_text.length() == 2 and not new_text.contains(":"):
			text = new_text + ":"
			# Move caret to the end for continued typing.
			caret_column = 3
	else:
		# If the input is invalid, revert to the last valid text.
		var current_caret_pos: int = caret_column
		text = _last_valid_text
		# Restore the caret position to be before the invalid character that was typed.
		caret_column = max(0, current_caret_pos - 1)


func _on_text_submitted(final_text: String) -> void:
	# When the user presses Enter, format the text.
	_finalize_input(final_text)


func _on_focus_exited() -> void:
	# When the user clicks away, also format the text.
	_finalize_input(text)


func _finalize_input(input: String) -> void:
	var parts = input.split(":", false, 1)
	var hour = -1
	var minute = -1

	if parts.size() >= 1 and parts[0].is_valid_int():
		hour = int(parts[0])

	if parts.size() == 2 and parts[1].is_valid_int():
		minute = int(parts[1])

	if hour < 0 or hour > 23 or minute < 0 or minute > 59:
		# If the time is invalid (e.g., "25:00" or "abc"), clear the LineEdit.
		text = ""
	else:
		# If valid, format it to HH:MM with leading zeros (e.g., "8:5" becomes "08:05").
		text = "%02d:%02d" % [hour, minute]
	
	_last_valid_text = text


func _is_valid_partial_input(input: String) -> bool:
	# This function validates the input as the user types.
	# It allows for partially complete, but valid, time strings.
	var parts = input.split(":", true, 1) # Split only once

	if parts.size() > 2: # More than one colon
		return false

	# Validate Hour Part
	var hour_str = parts[0]
	if not hour_str.is_empty():
		if not hour_str.is_valid_int(): return false
		if hour_str.length() > 2: return false
		var hour_val = int(hour_str)
		if hour_str.length() == 1 and hour_val > 2: return false # e.g., "3" is invalid as first digit
		if hour_str.length() == 2 and hour_val > 23: return false

	# Validate Minute Part
	if parts.size() == 2:
		var minute_str = parts[1]
		if not minute_str.is_empty():
			if not minute_str.is_valid_int(): return false
			if minute_str.length() > 2: return false
			var minute_val = int(minute_str)
			if minute_str.length() == 1 and minute_val > 5: return false # e.g., "12:6" is invalid
			if minute_str.length() == 2 and minute_val > 59: return false

	return true
