class_name AnimationHelper extends RefCounted
 
#region VARIABLES
# MAIN --------------------------
var node : CanvasItem
var tween : Tween
# ANIMATION PARAMETERS -----------
var trans_type : Tween.TransitionType
var ease_type : Tween.EaseType
## The time for one tween animation.
var anim_time : float
## Makes animations with sine quicker.
var def_sine_speed : float
## Can be used to set minimal values for methods that use sine.
var def_sine_offset : float
## Makes the final value from sine methods larger.
var def_sine_multiplier : float
# MISC ---------------------------
# Not sure why, but you don't get type hints using the Vector2i.Axis enum, so that's why this is here
## Used for stretching animations.
enum Axis {AXIS_X, AXIS_Y}
# --------------------------------
#endregion

#region CLASS/BUILT INS
# using this instead of _init for more customizability
## Returns a configurable AnimationHelper
static func create(obj : CanvasItem,\
 def_time : float = 0.35,\
  def_trans_type : Tween.TransitionType = Tween.TransitionType.TRANS_QUINT,\
   def_ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT\
   ) -> AnimationHelper:
	var result := AnimationHelper.new()
	result.node = obj
	result.anim_time = def_time
	result.trans_type = def_trans_type
	result.ease_type = def_ease_type
	return result
#endregion

#region ANIMATIONS
## Tween scale to a set size.
func grow(size : Vector2 = Vector2.ONE, duration : float = anim_time) -> void:
	animate()
	tween.tween_property(node, "scale", size, duration).set_trans(trans_type)

## Tween to a set size (Vector2.ZERO by default).
func shrink(size : Vector2 = Vector2.ZERO, duration : float = anim_time) -> void:
	animate()
	tween.tween_property(node, "scale", size, duration).set_trans(trans_type)

## Tween global pos (or optionally local position) to a new value.
func glide(to : Vector2, use_local_pos : bool = false, duration : float = anim_time) -> void:
	animate()
	tween.tween_property(node, "position" if use_local_pos else "global_position", to, duration).set_trans(trans_type)

## Just like Tween.tween_property, but for shader parameters.
## [br]NOTE: node needs to have a ShaderMaterial.
func tween_shader_parameter(which : StringName, to : Variant, duration : float = anim_time) -> void:
	animate()
	var shader : ShaderMaterial = node.get_material()
	var from : Variant = shader.get_shader_parameter(which)
	tween.tween_method(
		func(arg : Variant) -> void:
			shader.set_shader_parameter(which, arg),
			from, to, duration
	).set_trans(trans_type)

## Tween scale:x or scale:y
func stretch_axis(axis : Axis, to : float, duration : float = anim_time) -> void:
	animate()  
	tween.tween_property(node, "scale:x" if axis == Axis.AXIS_X else "scale:y", to, duration).set_trans(trans_type)
#endregion

#region MISC
## Wrapper for sin method to make it a little easier to customize.
static func get_sine(time : float, speed : float = 1, offset : float = 0, multiplier : float = 1) -> float:
	return sin(time * speed) * multiplier + offset

## Converts rotation in degrees to an orthogonal Vector2i
## NOTE: Use rotation_degrees property of 2D nodes and not rotation
static func rotation_dir_to_orthogonal_dir(rotation : float) -> Vector2i:
	var result : Vector2i
	var snapped_rot : int = snappedi(rotation, 90)
	var final_rot : int
	if snapped_rot < 360 and snapped_rot >= 0:
		final_rot = snapped_rot
	else:
		final_rot = snapped_rot - floor(snapped_rot / 360.0) * 360.0
	match final_rot:
		0:
			result = Vector2i.RIGHT
		90:
			result = Vector2i.DOWN
		180:
			result = Vector2i.LEFT
		270:
			result = Vector2i.UP
	return result

func animate() -> void:
	if tween:
		tween.kill()
	tween = node.create_tween()
#endregion
