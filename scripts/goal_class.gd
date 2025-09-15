class_name Goal
extends RefCounted

var id: int = -1
var goal_massage: String = ""
var mean_massage: String = ""
var created_at: int
var done_good: String = ""
var do_better: String = ""


func _init(goal_text: String, mean_text: String = "", done_good_text: String = "", do_better_text: String = "") -> void:
	self.goal_massage = goal_text
	self.mean_massage = mean_text
	self.created_at = int(Time.get_unix_time_from_system())
	self.done_good = done_good_text
	self.do_better = do_better_text


static func from_dictionary(data: Dictionary) -> Goal:
	var new_goal := Goal.new(data.get("goal"), data.get("mean", ""))
	new_goal.id = data.get("id", -1)
	new_goal.done_good = data.get("done_good", "")
	new_goal.do_better = data.get("do_better", "")
	if not new_goal.id or not new_goal.goal_massage:
		assert(false, "invalid goal_massage data from dictionary: " + str(data))
		return
	new_goal.created_at = data.get("created_at", 0)
	return new_goal


func to_dictionary() -> Dictionary:
	# This dictionary is for inserting new rows. ID is handled by auto-increment.
	if not id or not goal_massage:
		assert(false, "invalid goal_massage data from object")
		return {}
	return {
		"goal": goal_massage, "mean": mean_massage, "created_at": created_at, "done_good": done_good, "do_better": do_better,
	}
