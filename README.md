Scripts not in a folder can be downloaded and used independantly (go to that script and click download file or just copy the code to use them).  
Stuff in a folder needs everything else in that folder.  
What each script does:
- Pulser: Extends Node. When added as a child, can be set to "pulse" any property of its parent using sine. It has a few presets to get started, like scale. Useful for UI or basic animation
- Animation helper: Tween wrapper
- Counter: Extends Label. A label taht is meant to display a number. Its main feature is being able to (optionally) animate the amount changing instead of setting it directly. Pretty customizable, has exports for a prefix, suffix, trans/ease for the tweener, etc.
- RichCounter: Extends RichTextCounter. Same as Counter but has some options for bbcode
- ExtraCamera2D: Extends Camera2D. Has some extra camera utility
- ExtraMath: Has some static helper functions like range2d (returns Array[Vector2i], for grid based stuff) and RNG wrappers
- TrackPlayer: Audio stream player that plays a randomly selected track (with options on how to randomize). Didn't know about random stream resource when I made it though so it's kinda useless
