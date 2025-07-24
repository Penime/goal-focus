class_name Reminder
extends RefCounted

var id: int
var time: float
var repeat: float
var goal: int


func _init(at_time: float, repeat_interval: float, goal_id: int) -> void:
	self.time = at_time
	self.repeat = repeat_interval
	self.goal_id = goal_id


static func from_dictionary(data: Dictionary) -> Goal:
	var new_reminder = Reminder.new(data.get("time", 0.0), data.get("repeat", 0.0), data.get("goal_id"))
	new_reminder.id = data.get("id")
	return new_reminder


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	return {
		"time": time, "repeat": repeat, "goal_id": goal
	}
