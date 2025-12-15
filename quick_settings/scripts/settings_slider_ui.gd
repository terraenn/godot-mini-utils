class_name SettingsSlider extends Control

signal value_set(value : float)

func _ready() -> void:
	(%Slider as HSlider).value_changed.connect(value_set.emit)
