extends RigidBody3D

@export var acceleration_force: float = 500.0
var initial_direction: Vector3 
@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var particle = $CPUParticles3D

func _physics_process(delta):
	# Apply a constant force in the initial direction
	self.apply_central_force(initial_direction * acceleration_force)

func _ready() -> void:
	initial_direction = -transform.basis.z.normalized()
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
	
	particle.emitting = true
	particle.restart()
	attack.position.y = 0
	
	var dir = (global_transform.origin - attack.position).normalized()
	apply_central_impulse(dir * 1000 + Vector3.UP * 500.0)
	
	var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	apply_torque_impulse(spin_axis * 500)
	
