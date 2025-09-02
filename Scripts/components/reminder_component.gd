extends PanelContainer

@onready var reminder_label: Label = $ContantContainer/ReminderLabel
@onready var edit_texture_button: TextureButton = $ContantContainer/HBoxContainer/EditTextureButton
@onready var toggle_texture_button: TextureButton = $ContantContainer/HBoxContainer/ToggleTextureButton
@onready var delete_texture_button: TextureButton = $ContantContainer/HBoxContainer/DeleteTextureButton

var unix_time: int
