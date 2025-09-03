class_name GoalStatus
extends RefCounted

var id: int = -1
var status: String
var time_stamp: int
var goal: int = -1


func _init(status_text: String, timestamp: int, goal_id: int) -> void:
	self.status = status_text
	self.time_stamp = timestamp
	self.goal_id = goal_id


static func from_dictionary(data: Dictionary) -> Goal:
	var new_status = GoalStatus.new(data.get("status", ""), data.get("time_stamp", 0.0), data.get("goal_id", -1))
	new_status.id = data.get("id", -1)
	if not new_status.id or not new_status.status or not new_status.time_stamp:
		assert(false, "invalid status data from dictionary: " + str(data))
		return
	return new_status


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	if not id or not status or not time_stamp:
		assert(false, "invalid status data from object")
		return {}
	return {
		"status": status, "time_stamp": time_stamp, "goal_id": goal
	}
