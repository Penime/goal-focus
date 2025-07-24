class_name Goal
extends RefCounted

var id: int
var goal: String
var mean: String
var created_at: float
var current_status: String


func _init(goal_text: String, mean_text: String = "") -> void:
	self.goal = goal_text
	self.mean = mean_text
	self.created_at = Time.get_unix_time_from_system()
	self.current_status = "נוצר"


static func from_dictionary(data: Dictionary) -> Goal:
	var new_goal := Goal.new(data.get("goal", "???"), data.get("mean", "???"))
	new_goal.id = data.get("id")
	new_goal.created_at = data.get("created_at", 0.0)
	new_goal.current_status = data.get("current_status", "")
	return new_goal


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	return {
		"goal": goal, "mean": mean, "created_at": created_at, "current_status": current_status
	}
