extends Node3D

@onready var ragdoll = $Ragdoll #rigidbody
@onready var explosion = $Ragdoll/CPUParticles3D
@onready var target = $RigidBody3D
@onready var cam = $Camera3D

@export var main : PackedScene

func start_pressed():
	
	explosion.emitting = true
	explosion.restart()
	var dir = -(global_transform.origin - target.global_transform.origin).normalized()
	ragdoll.apply_central_impulse(dir * 100) 
	var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	ragdoll.apply_torque_impulse(spin_axis * 50.0)
	cam.shake(0.2, 5)
	
	await get_tree().create_timer(2).timeout
	cam.shake(0.1, 3)
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(main)
