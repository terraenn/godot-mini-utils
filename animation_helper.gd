class_name AnimationHelper extends RefCounted
 
# MAIN --------------------------
var node : CanvasItem
var tween : Tween:
	get:
		if reset_animations_on_new_animation and tween:
			tween.kill()
			return node.create_tween()
		return tween
# ANIMATION PARAMETERS -----------
var trans_type : Tween.TransitionType
var ease_type : Tween.EaseType
## The time for one tween animation.
var anim_time : float
## If false, multiple tween animations can be played at the same time
var reset_animations_on_new_animation : bool
## Makes animations with sine quicker.
var def_sine_speed : float
## Can be used to set minimal values for methods that use sine.
var def_sine_offset : float
## Makes the final value from sine methods larger.
var def_sine_multiplier : float
# --------------------------------

#region CLASS/BUILT INS
# using this instead of _init for more customizability
## Returns a configurable AnimationHelper
static func create(obj : CanvasItem,\
 def_time : float = 0.35,\
 def_kill_tween : bool = true,\
  def_trans_type : Tween.TransitionType = Tween.TransitionType.TRANS_QUINT,\
   def_ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT\
   ) -> AnimationHelper:
	var result := AnimationHelper.new()
	result.node = obj
	result.anim_time = def_time
	result.reset_animations_on_new_animation = def_kill_tween
	result.trans_type = def_trans_type
	result.ease_type = def_ease_type
	return result
#endregion

#region ANIMATIONS
## Tween scale to a set size.
func grow(size : Vector2 = Vector2.ONE) -> void:
	tween.tween_property(node, "scale", size, anim_time)

## Tween to a set size (Vector2.ZERO by default).
func shrink(size : Vector2 = Vector2.ZERO) -> void:
	tween.tween_property(node, "scale", size, anim_time)

## Tween global pos (or optionally local position) to a new value.
func glide(to : Vector2, use_local_pos : bool = false) -> void:
	tween.tween_property(node, "position" if use_local_pos else "global_position", to, anim_time)

## Just like Tween.tween_property, but for shader parameters.
## [br]NOTE: node needs to have a ShaderMaterial.
func tween_shader_parameter(which : StringName, to : Variant) -> void:
	var shader : ShaderMaterial = node.get_material()
	var from : Variant = shader.get_shader_parameter(which)
	tween.tween_method(
		func(arg : Variant) -> void:
			shader.set_shader_parameter(which, arg),
			from, to, anim_time
	)
#endregion

#region MISC
## Wrapper for sin method to make it a little easier to customize.
static func get_sine(time : float, speed : float = 1, offset : float = 0, multiplier : float = 1) -> float:
	return sin(time * speed) * multiplier + offset
#endregion
