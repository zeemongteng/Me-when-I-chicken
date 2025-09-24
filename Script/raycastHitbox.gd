class_name RaycastHitbox
extends RayCast3D

signal hit_enemy

@onready var projectile = get_owner()

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider is Hurtbox:
			var attack := Attack.new()
			attack.position = global_transform.origin
			collider.damage(attack)
			
			hit_enemy.emit()
			
			# Optional: disable ray after first hit (like a projectile disappearing)
			enabled = false
