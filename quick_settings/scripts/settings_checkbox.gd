class_name SettingsCheckbox extends Control

signal value_set(value : bool)

func _ready() -> void:
	(%CheckBox as CheckBox).toggled.connect(value_set.emit)
