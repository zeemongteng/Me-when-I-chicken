class_name Hitbox
extends Area3D

signal hit_enemy


@onready var projectile = get_owner()


func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area is Hurtbox:
		var attack := Attack.new()
		attack.position = global_transform.origin
		area.damage(attack)
		
		hit_enemy.emit()
