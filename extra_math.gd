## A collection of static utility methods related to math/RNG.
class_name ExtraMath extends RefCounted

#region RNG
## Returns a [Vector2] with the x and y being the same values.
## Mostly meant to be used to scale objects randomly and not get stretched sprites.
static func randv2_range(from : float, to : float) -> Vector2:
	var _randf : float = randf_range(from, to)
	return Vector2(_randf, _randf)
#endregion

#region ARRAY
## Returns an array with the given range. Meant to be used for tilemap related stuff.
## Just like the regular range, has 3 modes:
## [br][code]range_2d(n : Vector2i)[/code] - starts from Vector2i.ZERO and stops before n (n is [b]exclusive[/b]).
## [br][code]range_2d(b : Vector2i, n : Vector2i)[/code] - starts from b, increases by Vector2i.ONE and stops before n.
## [br][code]range_2d(b : Vector2i, n : Vector2i, s : Vector2i)[/code] - starts from b, increases/decreases by s and stops before n. s can be negative.
## [br][b]Tip: [/b]Add Vector2i.ONE to the stop argument to make it inclusive.
static func range_2d(...args : Array) -> Array[Vector2i]:
	var result : Array[Vector2i]
	args.assign(args as Array[Vector2i])
	if not args:
		result.erase(Vector2i.ZERO)
		return result # return empty array
	var x_args : Array[int]
	var y_args : Array[int]
	for i : Vector2i in args:
		x_args.append(i.x)
		y_args.append(i.y)
	for x : int in range.callv(x_args):
		for y : int in range.callv(y_args):
			result.append(Vector2i(x, y))
	return result
#endregion
