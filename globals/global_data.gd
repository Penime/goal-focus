extends Node

const STARTING_PAGE: PackedScene = preload("res://scenes/pages/start_form_page.tscn")
const GOAL_FORM_PAGE: PackedScene = preload("res://scenes/pages/goal_form_page.tscn")
const MEAN_FORM_PAGE: PackedScene = preload("res://scenes/pages/mean_form_page.tscn")
const REMINDERS_PAGE: PackedScene = preload("res://scenes/pages/reminders_page.tscn")
const NOTIFICATION = preload("res://scenes/pages/notification.tscn")
const REMINDER_COMPONENT = preload("res://scenes/components/reminder_component.tscn")

var procss_data := {}


func show_notification(text:="", duration:=2) -> Notification:
	var notification_node = NOTIFICATION.instantiate()
	notification_node.text = text
	notification_node.duration = duration
	get_tree().get_first_node_in_group(&"notifications").add_child(notification_node)
	return notification_node
