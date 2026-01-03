@tool
class_name Pulser extends Node

#region VARIABLES
var time : float = 0
# EXPORTS
@export var pulse : bool = true
@export var pulse_from : float = 0
@export var pulse_to : float = 1
@export var pulse_speed : float = 1
## The node path of the pulsed property relative to this Pulser's parent.
## E.g. - "position", "scale:x"
@export var property : String
# ONREADY
@onready var node : Node = get_parent()
#endregion

func _process(delta: float) -> void:
	time += delta
	if node and pulse:
		var foo : float = get_sine(pulse_from, pulse_to, pulse_speed)
		#node.scale = Vector2(foo, foo)
		var cur_val : Variant = node.get_indexed(NodePath(property).get_as_property_path())
		if cur_val is float:
			node.set_indexed(NodePath(property).get_as_property_path(), foo)
		elif cur_val is Vector2:
			node.set_indexed(NodePath(property).get_as_property_path(), Vector2(foo, foo))
		elif cur_val is Vector2i:
			node.set_indexed(NodePath(property).get_as_property_path(), Vector2i(roundi(foo), roundi(foo)))

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
