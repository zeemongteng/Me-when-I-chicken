extends Node3D
class_name Canon

@export var shoot_interval: float = 2.0
@export var turn_speed: float = 0.8
@export var bullet_speed: float = 100

@onready var bulletspawner: Node3D = $IntroPivot/Cannon_1/Pivot/Cannon_1_Gun/BulletSpawner
@onready var pivot: Node3D = $IntroPivot/Cannon_1/Pivot
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var bullet_scene: PackedScene = preload("res://Scene/bullet.tscn")
@onready var shoot_timer: Timer = Timer.new()
  
func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	add_child(shoot_timer)
	shoot_timer.timeout.connect(shoot)

func _process(_delta: float) -> void:
	var target: Node3D = null
	if !player.is_dead:
		target = player
	else:
		target = get_tree().get_first_node_in_group("ragdoll") # ADD

	if target == null:
		return

	var target_pos = target.global_position
	target_pos.y = pivot.global_position.y # I fucking hate my life
	var target_dir = (target_pos - pivot.global_position).normalized()
	var current_dir = -pivot.transform.basis.z
	var new_dir = current_dir.slerp(target_dir, turn_speed)
	pivot.look_at(pivot.global_position + new_dir, Vector3.UP)

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = bulletspawner.global_position

	var shoot_dir = -pivot.transform.basis.z.normalized()
	bullet.velocity = shoot_dir * bullet_speed
	bullet.look_at(bullet.global_position + shoot_dir, Vector3.UP)

	anim.play("shoot")
