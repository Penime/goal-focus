extends Node

func _ready():
	var time = Time.get_unix_time_from_system()
	print(HebrewDateConverter.GetHebrewDateStringFromUnix(time))
	
	var goal := {
		"goal": "some goal",
		"mean": "some mean",
		"reminders": [ {"time": 324.32, "repeat_time": 23433}],
		"created_at": {"year": 2025, "month": 11, "day": 24},
	}
	# create a separated table for reminders
