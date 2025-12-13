@tool
## [b]A [Label] that is meant to only store a number.[/b]
## [br]To use, set the amount property instead of text.
class_name Counter extends Label

#region VARIABLES & SIGNALS
# EXPORTS ---------
## How many decimals should be displayed.
@export_enum("0 (display as int)", "1", "2", "3", "Infinite") var max_decimals : int = 1:
	set(value):
		max_decimals = value
		displayed_amount = displayed_amount # update display
@export var amount : float:
	set(value):
		var old_value := amount
		amount = value
		animate_amount(value, old_value)
## Whether there should be a counting up/down animation on counter amount change above [member animation_threshold]
@export var animate_change : bool = false
@export_group("Animation", "animation")
## How much should the counter increase/decrease by to trigger an animation
@export var animation_threshold : int = 1
@export var animation_ease : Tween.EaseType = Tween.EaseType.EASE_IN
@export var animation_trans : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var animation_speed_multiplier : float = 0.25
@export_range(0.0, 1.0, 0.05, "or_greater") var animation_min_duration : float = 0.2
@export_range(0.5, 2.0, 0.05, "or_greater", "or_less") var animation_max_duration : float = 2.0
## Displayed before [displayed_amount]
@export var prefix : String
## Displayed after [displayed_amount]
@export var suffix : String
# REGULAR ---------
var displayed_amount : float:
	set(value):
		displayed_amount = value
		@warning_ignore("incompatible_ternary") # intentional
		text = str(roundi(value) if max_decimals == 0 else snappedf(value, pow(0.1, max_decimals)))
var tween : Tween
var snap_step : float = pow(0.1, max_decimals) 
# SIGNALS ---------
signal animation_triggered
signal animation_ended
# -----------------
#endregion

#region BUILT-IN
func _process(_delta : float) -> void:
	pass
#endregion

#region CLASS
func set_amount_directly(value : float) -> void:
	var toggle_animate_change := animate_change
	animate_change = false
	amount = value
	if toggle_animate_change:
		animate_change = true

# Using a method instead of a setter because setters can't be overwritten by subclasses
# This way subclasses can change the tweening logic if need be
# As of Godot 4.5 at least
## Tween the displayed amount from an old to a new value
func animate_amount(value : float, old_value : float) -> void:
	var change : float = abs(old_value - value)
	var displayed_new_value : float = snappedf(value, snap_step)
	if animate_change and change > animation_threshold:
		animation_triggered.emit()
		if tween:
			tween.kill()
		tween = create_tween()
		tween\
		.tween_property(self, "displayed_amount", value, clamp(change * animation_speed_multiplier, animation_min_duration, animation_max_duration))\
		.set_trans(animation_trans)\
		.set_ease(animation_ease)
		tween.tween_callback(animation_ended.emit)
	else:
		displayed_amount = displayed_new_value
#endregion
