extends Node

var _database: SQLite
var data_to_insert := {}

func _ready() -> void:
	_database = SQLite.new()
	_database.path = "res://data.db"
	_database.open_db()
	_create_tables()


func _create_tables() -> void:
	var goals_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"goal": {"data_type": "text", "not_null": true},
		"mean": {"data_type": "text"},
		"created_at": {"data_type": "real", "not_null": true},
		"current_status": {"data_type": "text", "not_null": true}
	}
	
	var reminder_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"time": {"data_type": "int", "not_null": true},
		"repeat": {"data_type": "int"},
		"goal_id": {"data_type": "int", "not_null": true, "foreign_key": "goals.id"}
	}
	
	var status_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"status": {"data_type": "text", "not_null": true},
		"time_stamp": {"data_type": "real"},
		"goal_id": {"data_type": "int", "not_null": true, "foreign_key": "goals.id"}
	}
	
	_database.create_table("goals", goals_table)
	_database.create_table("reminders", reminder_table)
	_database.create_table("status", status_table)


func get_all_goals() -> Array:
	var goals_dict = _database.select_rows("goals", "", ["*"])
	return goals_dict.map(func(goal): return Goal.from_dictionary(goal))

func get_goal_by_id(id: int) -> Goal:
	var goal_dict = _database.select_rows("goals", "where id = " + str(id), ["*"])
	return Goal.from_dictionary(goal_dict[0])


func get_reminders_by_goal_id(id: int) -> Array:
	_database.query("SELECT * FROM reminders
JOIN goals ON reminders.goal_id = goals.id
WHERE goals.id = " + str(id))
	return _database.query_result.map(func(reminder): return GoalReminder.from_dictionary(reminder))


func get_statuses_by_goal_id(id: int) -> Array:
	_database.query("SELECT * FROM status
JOIN goals ON status.goal_id = goals.id
WHERE goals.id = " + str(id))
	return _database.query_result.map(func(status): return GoalStatus.from_dictionary(status))


func update_goal(goal_id: int, goal_data: Goal) -> void:
	_database.update_rows("goals", "id = " + str(goal_id), goal_data.to_dictionary())


func update_reminder(reminder_id: int, reminder_data: GoalReminder) -> void:
	_database.update_rows("reminders", "id = " + str(reminder_id), reminder_data.to_dictionary())


func delete_goal(id: int) -> void:
	_database.delete_rows("goal", "id = " + str(id))


func delete_reminder(id: int) -> void:
	_database.delete_rows("reminders", "id = " + str(id))


func delete_all_reminders_by_goal_id(goal_id: int) -> void:
	_database.delete_rows("reminders", "goal_id = " + str(goal_id))


func delete_all_statuses_by_goal_id(goal_id: int) -> void:
	_database.delete_rows("status", "goal_id = " + str(goal_id))


# func clear_database() -> void:
# 	_database.delete_rows("goals", "id > 0")
# 	_database.delete_rows("reminders", "id > 0")
# 	_database.delete_rows("status", "id > 0")


func insert_goal(goal: Goal) -> void:
	_database.insert_row("goals", goal.to_dictionary())


func insert_reminder(reminder: GoalReminder) -> void:
	_database.insert_row("reminders", reminder.to_dictionary())


func insert_status(status: GoalStatus) -> void:
	_database.insert_row("status", status.to_dictionary())
