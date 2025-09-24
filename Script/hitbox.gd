class_name Hitbox
extends Area3D

signal hit_enemy


@onready var projectile = get_owner()
@onready var flash_ui: ColorRect = get_tree().root.get_node("Mainmenu/CanvasLayer/ColorRect")

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D):
	if area is Hurtbox:
		var attack := Attack.new()
		attack.position = global_transform.origin
		area.damage(attack)
		flash_ui.flash(0.1, Color.WHITE, 0.8)
		get_tree().paused = true
		await get_tree().create_timer(0.3).timeout
		get_tree().paused = false
		
		hit_enemy.emit()
