extends Camera3D

var shake_time: float = 0.0
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var original_transform: Transform3D

func _ready() -> void:
	original_transform = global_transform

func shake(duration: float, intensity: float) -> void:
	shake_time = duration
	shake_duration = duration
	shake_intensity = intensity

func _process(delta: float) -> void:
	if shake_time > 0.0:
		shake_time -= delta
		var progress: float = 1.0 - (shake_time / shake_duration)
		var current_intensity: float = lerp(shake_intensity, 0.0, progress)

		var offset: Vector3 = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * current_intensity * 0.05

		var rotation_offset: Vector3 = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * current_intensity * 0.01

		global_transform = original_transform.translated(offset)
		global_rotation += rotation_offset
	else:
		global_transform = original_transform
