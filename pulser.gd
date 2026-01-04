@tool
## "Pulses" a property of its parent using sine.
##
##[br] To use, add as a child of any node and set either [member property] or [member preset].
## The property functions as a [NodePath] relative to this Pulser's parent and
## can be anything numeric -  e.g. "scale", "position:x", "modulate".
## [br][b] [float], [int], [Vector2], [Vector2i] and [Color] is supported.
class_name Pulser extends Node

#region VARIABLES
## Used for [method get_sine]
var time : float = 0
# EXPORTS
@export_group("Pulse", "pulse_")
## Won't pulse if set to false.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var pulse_ : bool = true
## Start point for sine. 
@export var pulse_from : float = 0
## 
@export var pulse_to : float = 1
@export_range(0.1, 5, 0.1, "or_greater", "or_less") var pulse_speed : float = 1
## The node path of the pulsed property relative to this Pulser's parent.
## E.g. - "position", "scale:x"
@export var preset : Preset = Preset.CUSTOM:
	set(value):
		preset = value
		notify_property_list_changed()
@export var property : String:
	set(value):
		if name == "Pulser" or name == property.capitalize().validate_node_name() + "Pulser":
			name = value.capitalize() + "Pulser"
		property = value
# ONREADY
@onready var node : Node = get_parent()
#endregion

enum Preset {
	ALPHA,
	SCALE,
	CUSTOM,
}

func _process(delta: float) -> void:
	time += delta
	if node and pulse_:
		var foo : float = get_sine(pulse_from, pulse_to, pulse_speed)
		#node.scale = Vector2(foo, foo)
		if preset == Preset.SCALE:
			node.scale = Vector2(foo, foo)
			return
		elif preset == Preset.ALPHA:
			node.modulate.a = foo
			return
		var cur_val : Variant = node.get_indexed(NodePath(property).get_as_property_path())
		if cur_val is float:
			node.set_indexed(NodePath(property).get_as_property_path(), foo)
		elif cur_val is Vector2:
			node.set_indexed(NodePath(property).get_as_property_path(), Vector2(foo, foo))
		elif cur_val is Vector2i:
			node.set_indexed(NodePath(property).get_as_property_path(), Vector2i(roundi(foo), roundi(foo)))
		elif cur_val is Color:
			node.set_indexed(NodePath(property).get_as_property_path(), Color(foo, foo, foo, foo))

func _validate_property(property_dict: Dictionary) -> void:
	if property_dict.name == "property":
		if preset == Preset.CUSTOM:
			property_dict.usage |= PROPERTY_USAGE_DEFAULT
		else:
			property_dict.usage |= PROPERTY_USAGE_READ_ONLY

## Set a target that should be pulser around and by how much (variation) it should pulse.
## [member pulse_from] and [member pulse_to] will be automatically set.
func set_target(target : float, variation : float) -> void:
	pulse_from = target - variation
	pulse_to = target + variation

## Returns current target (which can be set using [method set_target])
## using [member pulse_from] and [member pulse_to]
func get_target() -> float:
	return pulse_from + ((pulse_to - pulse_from) / 2)

## Like [method set_target], but tweens to the target. Not variation though
func smooth_set_target(target : float, variation : float, length : float = -1,) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(tar : float) -> void:
			set_target(tar, variation),
			get_target(), target, length if length != -1 else clampf(absf(target - get_target() * 0.2), 0.3, 2.0)
	)

## I forgot what this one does. It's some fancy formula I wrote
func get_sine(from : float, to : float, speed : float = 1) -> float:
	return sin(time * speed) * (to - from) / 2.0 + (to - (to - from) / 2.0)
