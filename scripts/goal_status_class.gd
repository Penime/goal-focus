class_name Status
extends RefCounted

var id: int
var status: String
var time_stamp: float
var goal: int


func _init(status_text: String, timestamp: float, goal_id: int) -> void:
	self.status = status_text
	self.time_stamp = timestamp
	self.goal_id = goal_id


static func from_dictionary(data: Dictionary) -> Goal:
	var new_status = Status.new(data.get("status", "???"), data.get("time_stamp", 0.0), data.get("goal_id"))
	new_status.id = data.get("id")
	return new_status


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	return {
		"status": status, "time_stamp": time_stamp, "goal_id": goal
	}
