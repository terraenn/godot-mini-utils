@tool
class_name ExtraCamera2D extends Camera2D

#region VARIABLES
@export var def_shake_amount_range : Vector2 = Vector2(5, 15)
@export var def_shake_duration : float = 0.5
@export var shaking : bool
@export var pan : bool = false:
	set(value):
		pan = value
		if pan:
			state = State.PAN
@export_range(0.5, 2.5, 0.1) var pan_speed : float = 1.0
var time : float
var state : State = State.STATIC
enum State {STATIC, PAN}
#endregion

#region BUILT-IN
func _process(delta: float) -> void:
	time += delta
	if shaking:
		offset =\
		 randv2_range(float_to_vector2(def_shake_amount_range.x), float_to_vector2(def_shake_amount_range.y))
	elif pan:
		offset =\
		 float_to_vector2(sin(time * pan_speed) * 5)
#endregion

#region ANIMATIONS
func shake(duration : float = def_shake_duration) -> void:
	shaking = true                                                                                                                                                                                                                                                                                       
	await get_tree().create_timer(duration).timeout
	shaking = false
#endregion

#region MISC
func randv2_range(from : Vector2, to : Vector2) -> Vector2:
	return Vector2(randf_range(from.x, to.x), randf_range(from.y, to.y))

func float_to_vector2(num : float) -> Vector2:
	return Vector2(num, num)
#endregion
