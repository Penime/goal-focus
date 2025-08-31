class_name TimeSelectorLineEdit
extends LineEdit

@onready var time_selector_canvas_layer: CanvasLayer = $TimeSelectorCanvasLayer
@onready var hour_buttons_container: VBoxContainer = $TimeSelectorCanvasLayer/MarginContainer/ContentContainer/TimeSelectorContainer/HourButtonsScrollContainer/HourButtonsContainer
@onready var minute_buttoontainer: VBoxContainer = $TimeSelectorCanvasLayer/MarginContainer/ContentContainer/TimeSelectorContainer/MinuteButtonsScrollContainer/MinuteButtoontainer
@onready var clock_button: Button = $"../ClockButton"

var _last_valid_text: String = ""
var hour: String: set = _set_hour
var minute: String: set = _set_minute
var _hour_selected = false
var _minute_selected = false


func _set_hour(new_hour: String) -> void:
	if not new_hour.is_valid_int():
		return
	hour = new_hour
	var parts = text.split(":", false, 1)
	if parts.size() == 2 and parts[1].is_valid_int():
		text = new_hour + ":" + parts[1]
	else:
		text = new_hour + ":00"


func _set_minute(new_minute: String) -> void:
	if not new_minute.is_valid_int():
		return
	minute = new_minute
	var parts = text.split(":", false, 1)
	if parts.size() >= 1 and parts[0].is_valid_int():
		text = parts[0] + ":" + new_minute
	else:
		text = "00:" + new_minute


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

	# connect all selected signal of buttons
	for button in hour_buttons_container.get_children():
		button.selected.connect(_on_hour_button_pressed)
	for button in minute_buttoontainer.get_children():
		button.selected.connect(_on_minute_button_pressed)
	
	clock_button.pressed.connect(_on_clock_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		time_selector_canvas_layer.hide()
		clock_button.release_focus()
		_hour_selected = false
		_minute_selected = false


func _on_text_changed(new_text: String) -> void:
	# This signal is emitted when the text changes, but also when we change it from code.
	# To prevent an infinite loop, we check if the new_text is the same as the last valid one.
	if new_text == _last_valid_text:
		return

	if _is_valid_partial_input(new_text):
		var parts = new_text.split(":", false, 1)

		var hour_str = parts[0]
		# If the user types a single digit hour greater than 2 (e.g., '3'),
		# automatically prepend a '0' and add a colon, making it "03:".
		if hour_str.length() == 1 and int(hour_str[0]) > 2:
			new_text = "0" + hour_str[0] + ":"
			text = new_text
			_last_valid_text = new_text
			caret_column = 3
		
		if parts.size() == 2:
			var minute_str = parts[1]
			# If the user types a single digit minute greater than 5 (e.g., '7' in "12:7"),
			# automatically prepend a '0', making it "12:07".
			if int(minute_str[0]) > 5:
				new_text = hour_str + ":" + "0" + minute_str[0]
				text = new_text
				_last_valid_text = new_text
				caret_column = 5

		_last_valid_text = new_text
		# A small UX improvement: automatically add the colon after a valid hour is typed.
		if new_text.length() == 2 and not new_text.contains(":"):
			text = new_text + ":"
			# Move caret to the end for continued typing.
			caret_column = 3
	else:
		# If the input is invalid, revert to the last valid text.
		var current_caret_pos: int = caret_column
		if _last_valid_text.length() != 2:
			text = _last_valid_text
		else:
			text = _last_valid_text + ":"
			current_caret_pos += 1
		# Restore the caret position to be before the invalid character that was typed.
		caret_column = max(0, current_caret_pos - 1)


func _on_text_submitted(final_text: String) -> void:
	# When the user presses Enter, format the text.
	_finalize_input(final_text)


func _on_focus_exited() -> void:
	# When the user clicks away, also format the text.
	_finalize_input(text)


func _on_hour_button_pressed(time_text: String) -> void:
	_hour_selected = true
	hour = time_text
	if _minute_selected and _hour_selected:
		time_selector_canvas_layer.hide()


func _on_minute_button_pressed(time_text: String) -> void:
	_minute_selected = true
	minute = time_text
	if _minute_selected and _hour_selected:
		time_selector_canvas_layer.hide()


func _on_clock_pressed() -> void:
	for hour_button in hour_buttons_container.get_children():
		if hour_button.text == hour:
			hour_button.button_pressed = true
			break
	for minute_button in minute_buttoontainer.get_children():
		if minute_button.text == minute:
			minute_button.button_pressed = true
			break
	
	time_selector_canvas_layer.show()
	_hour_selected = false
	_minute_selected = false


func _finalize_input(input: String) -> void:
	var parts = input.split(":", false, 1)
	var hour_int = -1
	var minute_int = -1

	if parts.size() >= 1 and parts[0].is_valid_int():
		hour_int = int(parts[0])

	if parts.size() == 2 and parts[1].is_valid_int():
		minute_int = int(parts[1])

	if hour_int < 0 or hour_int > 23 or minute_int < 0 or minute_int > 59:
		# If the time is invalid (e.g., "25:00" or "abc"), clear the LineEdit.
		text = ""
	else:
		# If valid, format it to HH:MM with leading zeros (e.g., "8:5" becomes "08:05").
		text = "%02d:%02d" % [hour_int, minute_int]
		hour = "%02d" % [hour_int]
		minute = "%02d" % [minute_int]
	
	_last_valid_text = text


func _is_valid_partial_input(input: String) -> bool:
	if input.is_empty():
		text = ""
		_last_valid_text = text
		return false

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
		# var hour_val = int(hour_str)
		# if hour_str.length() == 1 and hour_val > 2: return false # e.g., "3" is invalid as first digit
		# if hour_str.length() == 2 and hour_val > 23: return false

	# Validate Minute Part
	if parts.size() == 2:
		var minute_str = parts[1]
		if not minute_str.is_empty():
			if not minute_str.is_valid_int(): return false
			if minute_str.length() > 2: return false
			# var minute_val = int(minute_str)
			# if minute_str.length() == 1 and minute_val > 5: return false # e.g., "12:6" is invalid
			# if minute_str.length() == 2 and minute_val > 59: return false

	return true
