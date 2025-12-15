class_name SettingsUI extends Control

#region VARIABLES
# NODE -----------------------------
@onready var blur : ColorRect = %Blur
@onready var outer_panel : Panel = %OuterPanel
# MISC -----------------------------
@onready var blur_shader : ShaderMaterial = blur.get_material()
# CUSTOMIZATION (WIP) -------------------- 
@export_range(0.5, 5.0, 0.1, "or_less") var blur_end : float = 2.5
# ----------------------------------
#endregion

#region BUILT-IN
func _ready() -> void:
	appear()
	# manually connect the signal of each child to on_settings_set
	# code for volume and screenshake options:
	# ---------------------------------------
	#(%Volume as SettingsSlider).value_set.connect(
		#func(val : float) -> void:
			#_on_settings_set("volume", val)
	#)
	#(%Screenshake as SettingsCheckbox).value_set.connect(
		#func(val : bool) -> void:
			#_on_settings_set("screenshake", val)
	#)
	# -----------------------------------------
#endregion

#region LOGIC
func _on_settings_set(_setting_name : String, _value : Variant) -> void:
	pass # insert logic here
	# emit SignalBus signal, change Globals variable, etc.
#endregion

#region ANIMATIONS
func appear() -> void:
	outer_panel.pivot_offset = outer_panel.size / 2
	outer_panel.scale = Vector2.ZERO
	var tween := create_tween().set_parallel()
	tween.tween_method(
		func(val : float) -> void:
			blur_shader.set_shader_parameter("lod", val),
			0.0, blur_end, 0.5
	).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(outer_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_QUINT)
	
func disappear() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_method(
		func(val : float) -> void:
			blur_shader.set_shader_parameter("lod", val),
			blur_end, 0.0, 0.5
	).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(outer_panel, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_QUINT)
	tween.chain().tween_callback(queue_free)
#endregion
