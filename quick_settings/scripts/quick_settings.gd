@tool
## To use instantiate somewhere where it'll drawn above the rest of the game.
## That should probably be a separate [CanvasLayer].
##[br]To customize, change the values of the exports and/or the resources in the folder with the same name.
class_name SettingsUI extends Control

#region VARIABLES & ENUMS
# NODE -----------------------------
@onready var blur : ColorRect = %Blur
@onready var outer_panel : Panel = %OuterPanel
# MISC -----------------------------
@onready var blur_shader : ShaderMaterial = blur.get_material()
var time : float = 0
var animate : bool = false
var global_tween : Tween
# CUSTOMIZATION (WIP) ---------------
@export_range(0.5, 5.0, 0.1, "or_less") var blur_end : float = 2.5
@export_flags("Blur pulse") var animations : int
# TOOL -----------------------------
@export_tool_button("Appear") var appear_var : Callable = appear
@export_tool_button("Disappear") var disappear_var : Callable = disappear
# ENUM -----------------------------
enum Animations {
	BLUR_PULSE = 1 << 0
}
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
	global_tween = create_tween()
	if animations == Animations.BLUR_PULSE:
		global_tween.tween_method(
			func(val : float) -> void:
				blur_shader.set_shader_parameter("lod", val),
			0.0, sin(time * 2.5) + blur_end, 0.5
	).set_trans(Tween.TRANS_QUINT)
	global_tween.tween_callback(set.bind("animate", true))

func _process(delta: float) -> void:
	if animate:
		time += delta
		match animations:
			Animations.BLUR_PULSE:
				blur_shader.set_shader_parameter("lod", sin(time) * 0.5 + blur_end)
#endregion

#region LOGIC
## Intended to be connected to value_set signals of setting options in the tree.
func _on_settings_set(_setting_name : String, _value : Variant) -> void:
	pass # insert logic here
	# match setting name, then emit SignalBus signal, change Globals variable, etc.

## Called at the start of [method appear].
func _on_open() -> void:
	pass # insert logic here
	# pause the game, make the music more muted, etc.

## Called at the end of [method disappear].
func _on_close() -> void:
	pass # insert logic here
	# undo what was done in _on_open or add some additional logic
#endregion

#region ANIMATIONS
## Tween scale to Vector2(1, 1) and blur the background.
func appear() -> void:
	_on_open()
	outer_panel.pivot_offset = outer_panel.size / 2
	outer_panel.scale = Vector2.ZERO
	global_tween = create_tween().set_parallel()
	global_tween.tween_method(
		func(val : float) -> void:
			blur_shader.set_shader_parameter("lod", val),
			0.0, blur_end, 0.5
	).set_trans(Tween.TRANS_QUINT)
	global_tween.tween_property(outer_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_QUINT)

## Unblur the background, shrink and queue free.
func disappear() -> void:
	if global_tween:
		global_tween.kill()
	global_tween = create_tween().set_parallel()
	global_tween.tween_method(
		func(val : float) -> void:
			blur_shader.set_shader_parameter("lod", val),
			blur_shader.get_shader_parameter("lod"), 0.0, 0.5
	).set_trans(Tween.TRANS_QUINT)
	global_tween.tween_property(outer_panel, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_QUINT)
	global_tween.chain().tween_callback(_on_close)
	if not Engine.is_editor_hint(): # crashes otherwise
		global_tween.chain().tween_callback(queue_free)
#endregion
