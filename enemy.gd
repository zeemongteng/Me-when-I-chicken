extends RigidBody3D

@export var acceleration_force: float = 120.0 # Adjust this value as needed
var initial_direction: Vector3 # This will be set by the spawner

func _physics_process(delta):
	# Apply a constant force in the initial direction
	self.apply_central_force(Vector3.FORWARD * acceleration_force)

func _ready() -> void:
	await get_tree().create_timer(10).timeout
	queue_free()
