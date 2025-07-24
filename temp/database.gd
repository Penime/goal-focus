extends Node

@onready var database: SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data/data.db"
	database.open_db()
	_create_tables()
	print(get_all_goals())


func _create_tables() -> void:
	var goals_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"goal": {"data_type": "text", "not_null": true},
		"mean": {"data_type": "text"},
		"created_at": {"data_type": "real", "not_null": true},
		"current_status": {"data_type": "txt", "not_null": true}
	}
	
	var reminder_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"time": {"data_type": "real", "not_null": true},
		"repeat": {"data_type": "real"},
		"goal_id": {"data_type": "int", "not_null": true, "foreign_key": "goals.id"}
	}
	
	var status_table := {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"status": {"data_type": "text", "not_null": true},
		"time_stamp": {"data_type": "real"},
		"goal_id": {"data_type": "int", "not_null": true, "foreign_key": "goals.id"}
	}
	
	database.create_table("goals", goals_table)
	database.create_table("reminders", reminder_table)
	database.create_table("status", status_table)


func get_all_goals() -> Array:
	return database.select_rows("goals", "", ["*"])


func get_goal_by_id(id: int) -> Array:
	return database.select_rows("goals", "where id = " + str(id), ["*"])


func get_reminders_by_goal_id(id: int) -> Array:
	database.query("SELECT * FROM reminders
JOIN goals ON reminders.goal_id = goals.id
WHERE goals.id = " + str(id))
	return database.query_result


func get_statuses_by_goal_id(id: int) -> Array:
	database.query("SELECT * FROM status
JOIN goals ON status.goal_id = goals.id
WHERE goals.id = " + str(id))
	return database.query_result


func update_goal(goal_id: int, data: Dictionary) -> void:
	database.update_rows("goals", "id = " + str(goal_id), data)


func update_reminder(reminder_id: int, data: Dictionary) -> void:
	database.update_rows("reminders", "id = " + str(reminder_id), data)


func delete_goal(id: int) -> void:
	database.delete_rows("goal", "id = " + str(id))
