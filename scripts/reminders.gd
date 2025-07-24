class_name Reminder
extends RefCounted

var id: int = -1
var time: float
var repeat: float
var goal: int


func _init(at_time: float, goal_id: int) -> void:
	self.time = at_time
	self.goal_id = goal_id


static func from_dictionary(data: Dictionary) -> Goal:
	var new_reminder = Reminder.new(data.get("time", 0.0), data.get("goal_id"))
	new_reminder.id = data.get("id", -1)
	if not new_reminder.id or not new_reminder.time:
		assert(false, "invalid reminder data from dictionary: " + str(data))
		return
	new_reminder.repeat = data.get("repeat", 0.0)
	return new_reminder


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	if not id or not time:
		assert(false, "invalid reminder data from object")
		return {}
	return {
		"time": time, "repeat": repeat, "goal_id": goal
	}
