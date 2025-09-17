extends RigidBody3D

@export var acceleration_force: float = 500.0 # Adjust this value as needed
var initial_direction: Vector3 # This will be set by the spawner

func _physics_process(delta):
	# Apply a constant force in the initial direction
	self.apply_central_force(Vector3.FORWARD * acceleration_force)

func _ready() -> void:
	await get_tree().create_timer(10).timeout
	queue_free()

func on_hit(attack: Attack):
	
	var collision_shape = $CollisionShape3D
	var hitbox = $Hitbox/CollisionShape3D
	var hurtbox = $Hurtbox/CollisionShape3D
	if collision_shape:
		collision_shape.disabled = true
		hitbox.disabled = true
		hurtbox.disabled = true
	
	attack.position.y = 0
	
	var dir = (global_transform.origin - attack.position).normalized()
	apply_central_impulse(dir * 1000 + Vector3.UP * 500.0)
	
	var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	apply_torque_impulse(spin_axis * 500)
	
