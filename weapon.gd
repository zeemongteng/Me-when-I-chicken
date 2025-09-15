extends Node3D
class_name Canon

@export var bulletspawner: Node3D
@export var pivot: Node3D # rotates to face the player
@export var shoot_interval: float = 2.0 # seconds between shots
@export var turn_speed: float = 1# higher = faster turning
@export var bullet_speed: float = 100


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var player: Node3D 
@onready var bullet_scene: PackedScene = preload("res://bullet.tscn")
@onready var shoot_timer: Timer = Timer.new()

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	shoot_timer.wait_time = shoot_interval
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	add_child(shoot_timer)
	shoot_timer.timeout.connect(shoot)

func _process(delta: float) -> void:
	if player:
		# Target position on same Y plane (horizontal only)
		var target_pos = player.global_position
		target_pos.y = pivot.global_position.y
		
		# Get direction toward player
		var target_dir = (target_pos - pivot.global_position).normalized()
		
		# Current forward direction of pivot
		var current_dir = -pivot.transform.basis.z
		
		# Smoothly interpolate between current and target direction
		var new_dir = current_dir.slerp(target_dir, turn_speed)
		
		# Reconstruct a rotation looking at new_dir
		var up = Vector3.UP
		pivot.look_at(pivot.global_position + new_dir, up)

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = bulletspawner.global_position

	# direction toward player (with Y difference this time, so bullet travels correctly)
	var shoot_dir = -pivot.transform.basis.x.normalized()

	bullet.velocity = shoot_dir * bullet_speed 
	bullet.rotation = shoot_dir

	anim.play("shoot")
