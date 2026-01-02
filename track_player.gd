class_name TrackPlayer extends AudioStreamPlayer

#region VARIABLES, SIGNALS & ENUMS

# VARIABLES (DYNAMIC) ----
@export var tracks : Array[AudioStream] = []
@export var randomize_type : RandomizerType = RandomizerType.SHUFFLE_BAG
@export var start_on_ready : bool = false
@export_range(0, 2, 0.1) var between_track_time : float = 1
var shuffle_bag : Array[AudioStream] = []
var last_track : AudioStream
@export var target_volume : float = 2
# -------------------------

# VARIABLES (FADE) -------
@export_group("Fade", "fade_")
@export var fade_in_track : bool = true
@export var fade_out_track : bool = true
@export var fade_length : float = 0.2
# -------------------------

# SIGNALS -----------------

# -------------------------

# ENUMS -------------------
enum RandomizerType {
	NORMAL,
	SHUFFLE_BAG,
	ANY_BUT_LAST_ONE,
}
# -------------------------

#endregion

#region BUILT-IN
func _ready() -> void:
	if start_on_ready:
		start_playing()
#endregion

#region CLASS
func start_playing() -> void:
	for i in range(9999999):
		play_random_track()
		await finished
		print("finished")
		await get_tree().create_timer(between_track_time).timeout
	

func play_random_track() -> void:
	#if fade_in_track:
		#var tween := create_tween()
		#tween.tween_property(self, "volume_linear", target_volume, fade_length)\
		#.set_delay(stream.get_length() - fade_length)\
		#.set_ease(Tween.EASE_IN)
	stream = get_random_track()
	volume_linear = target_volume
	play()
	if fade_out_track:
		var tween := create_tween()
		tween.tween_property(self, "volume_linear", 0, fade_length)\
		.set_delay(stream.get_length() - fade_length)\
		.set_ease(Tween.EASE_OUT)
		tween.tween_callback(set.bind("volume_linear", target_volume)).set_delay(fade_length)

func get_random_track() -> AudioStream:
	var result : AudioStream
	match randomize_type:
		RandomizerType.NORMAL:
			result = tracks.pick_random()
			last_track = result
		RandomizerType.SHUFFLE_BAG:
			if shuffle_bag:
				result = shuffle_bag.pick_random()
				shuffle_bag.erase(result)
				last_track = result
			else:
				shuffle_bag.append_array(tracks)
				result = shuffle_bag.pick_random()
				last_track = result
				shuffle_bag.erase(result)
		RandomizerType.ANY_BUT_LAST_ONE:
			if last_track:
				shuffle_bag = []
				shuffle_bag.append_array(tracks)
				shuffle_bag.erase(last_track)
				result = shuffle_bag.pick_random()
				last_track = result
			else:
				result = tracks.pick_random()
				last_track = result
	return result
#endregion
