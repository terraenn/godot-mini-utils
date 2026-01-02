@tool
## A version of [Counter] that extends [RichTextLabel] instead of [Label]
## which allows using BBcode.
class_name RichTextCounter extends RichTextLabel

#region VARIABLES & SIGNALS
# EXPORTS ---------
## The current, actual, amount.
var amount : Variant:
	set(value):
		var old_value : Variant = amount
		amount = value
		# set displayed amount
		if animate and absf(value - old_value) > animation_threshold:
			set_amount_animated(value, old_value)
		else:
			displayed_amount = value
## How many decimals should be displayed max.
@export_group("Style")
@export_enum("0 (display as int)", "1", "2", "3", "Infinite") var max_decimals : int = 0:
	set(value):
		max_decimals = value
		displayed_amount = displayed_amount # update display 
## Displayed before [member displayed_amount]
@export var prefix : String:
	set(value):
		prefix = value
		update_text()
## Displayed after [member displayed_amount]
@export var suffix : String:
	set(value):
		suffix = value
		update_text()
## The BBcode applied to the [member displayed_amount], not including the [member prefix] and the [member suffix].
## [br] For example, if the value is [code]["b", "wave"][/code],
## then the text will be [code]"prefix[b][wave]amount[/b][/wave]suffix"[/code]
##[br][b]Note:[/b] [member RichTextLabel.bbcode_enabled] has to be set to true.
@export var amount_bbcode : Array[String]
## Whether anything should be displayed when amount is 0.
@export var hide_on_zero : bool = false:
	set(value):
		hide_on_zero = value
		update_text()
@export_group("Animation")
## Whether there should be a counting up/down animation on counter amount change above [member animation_threshold].
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var animate : bool = false
## How much should the [member amount] increase/decrease by to trigger an animation.
@export var animation_threshold : int = 1
## The ease the animation uses.
@export var animation_ease : Tween.EaseType = Tween.EaseType.EASE_IN
## The transition type the animation uses.
@export var animation_trans : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
## Used in the formula for the duration of the animation.
@export var animation_speed_multiplier : float = 0.25
## Used in the formula for the duration of the animation.
@export_range(0.0, 1.0, 0.05, "or_greater") var animation_min_duration : float = 0.2
## Used in the formula for the duration of the animation.
@export_range(0.5, 2.0, 0.05, "or_greater", "or_less") var animation_max_duration : float = 2.0
@export_group("", "")
# REGULAR ---------
## The number that's displayed right now. ([int] or [float])
var displayed_amount : Variant:
	set(value):
		@warning_ignore("incompatible_ternary") # intentional
		displayed_amount = roundi(value) if max_decimals == 0 or is_equal_approx(value, 0) else snapped(value, pow(0.1, max_decimals))
		if hide_on_zero and is_equal_approx(floorf(displayed_amount), 0):
			text = ""
			return
		text =\
		prefix + bbcode_start + str(displayed_amount) + bbcode_end + suffix
## Used to reset animation when amount is changed again
var tween : Tween
## Used for rounding.
var snap_step : float = pow(0.1, max_decimals)
var bbcode_start : String:
	get:
		var result : String = ""
		for i in amount_bbcode:
			result += "[%s]" % i
		return result
var bbcode_end : String:
	get:
		var result : String = ""
		for i in amount_bbcode:
			result += "[/%s]" % i
		return result
# SIGNALS ---------
## Emitted when the counting animation is triggered, i.e. when [method set_amount_animated] is called.
signal animation_triggered
## Emitted when the counting animation is finished, i.e. at the end of [method set_amount_animated].
signal animation_ended
# -----------------
#endregion

##region BUILT-IN
func _get_property_list() -> Array[Dictionary]:
	var result : Array[Dictionary]
	result.append(
		{
			"name": "amount",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
		}
	)
	return result
#endregion

#region CLASS
## Set the amount without an animation.
func set_amount_directly(value : float) -> void:
	var toggle_animate := animate
	animate = false
	amount = value
	if toggle_animate:
		animate = true
  
# Using a method instead of a setter because setters can't be overwritten by subclasses
# This way subclasses can change the tweening logic if need be
# As of Godot 4.5 at least
## Tween the displayed amount from an old to a new value.
func set_amount_animated(value : Variant, old_value : Variant) -> void:
	var change : float = abs(old_value - value)
	animation_triggered.emit()
	if tween:
		tween.kill()                                                               
	tween = create_tween()
	tween\
	.tween_property(self, "displayed_amount", value, clamp(change * animation_speed_multiplier, animation_min_duration, animation_max_duration))\
	.set_trans(animation_trans)\
	.set_ease(animation_ease)
	tween.tween_callback(animation_ended.emit)

## Update [member text] to be [member displayed_amount].
func update_text() -> void:
	displayed_amount = displayed_amount
#endregion
