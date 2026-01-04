@tool
class_name Pulser extends Node

#region VARIABLES
var time : float = 0
# EXPORTS
@export_group("Pulse", "pulse_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var pulse_ : bool = true
@export var pulse_from : float = 0
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

#func _get_property_list() -> Array[Dictionary]:
	#var result : Array[Dictionary]
	#result.append(
		#{
			#"name": "property",
			#"type": TYPE_NODE_PATH,
			#"hint": PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE,
			##"hint_string": "ZERO,ONE,TWO,THREE,FOUR,FIVE",
		#}
	#)
	#return result

func get_sine(from : float, to : float, speed : float = 1) -> float:
	return sin(time * speed) * (to - from) / 2.0 + (to - (to - from) / 2.0)
