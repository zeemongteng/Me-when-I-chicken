extends Camera3D

@export var player: Player
@export var follow_offset := Vector3(0.0, 45.0, 13.0)
@export var look_at_offset := Vector3(0, 0, 0)

@export var shake_strength: float = 0.3
@export var shake_duration: float = 0.25
@export var transition_speed: float = 3.0 # speed of cinematic transition

var target: Node3D
var _previous_target: Node3D
var _transition_progress := 1.0
var _shake_time: float = 0.0

func shake(duration: float, strength: float) -> void:
	shake_duration = duration
	shake_strength = strength
	_shake_time = shake_duration

func _process(delta: float) -> void:
	# Determine current target
	if !player.is_dead:
		if target != player:
			_previous_target = target
			target = player
			_transition_progress = 0.0
	else:
		var ragdoll = get_tree().get_first_node_in_group("ragdoll")
		if ragdoll != null and target != ragdoll:
			_previous_target = target
			target = ragdoll
			_transition_progress = 0.0

	if target == null:
		return

	# Smooth transition
	_transition_progress = clamp(_transition_progress + delta * transition_speed, 0, 1)
	var current_position = target.global_transform.origin + follow_offset
	var current_look_at = target.global_transform.origin + look_at_offset

	if _previous_target != null and _transition_progress < 1.0:
		var prev_position = _previous_target.global_transform.origin + follow_offset
		var prev_look_at = _previous_target.global_transform.origin + look_at_offset
		current_position = prev_position.lerp(current_position, _transition_progress)
		current_look_at = prev_look_at.lerp(current_look_at, _transition_progress)

	# Apply shake
	var final_position = current_position
	var final_rotation := Vector3.ZERO

	if _shake_time > 0.0:
		_shake_time -= delta
		var strength = shake_strength * (_shake_time / shake_duration)

		final_position += Vector3(
			randf_range(-strength, strength),
			randf_range(-strength, strength),
			randf_range(-strength, strength) * 0.5
		)

		final_rotation = Vector3(
			randf_range(-strength, strength) * 0.1,
			randf_range(-strength, strength) * 0.1,
			0
		)

	# Set final transform
	global_transform.origin = final_position
	look_at(current_look_at, Vector3.UP)

	if final_rotation != Vector3.ZERO:
		rotate_object_local(Vector3.RIGHT, final_rotation.x)
		rotate_object_local(Vector3.UP, final_rotation.y)
