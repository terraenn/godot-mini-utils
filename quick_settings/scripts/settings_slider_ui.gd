class_name SettingsSlider extends Control

@onready var counter : RichTextCounter = %Counter
signal value_set(value : float)

func _ready() -> void:
	(%Slider as HSlider).value_changed.connect(value_set.emit)
	(%Slider as HSlider).value_changed.connect(
		func(val : float) -> void:
			counter.amount = val
	)
