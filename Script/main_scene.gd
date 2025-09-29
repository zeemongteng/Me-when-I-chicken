extends Node3D

@export var mob_scene: PackedScene
@export var spawn_interval_mob: float = 3.0
@export var weapon_scenes: Array[PackedScene]
@export var spawn_interval_weapon: float = 5.0

@onready var player: Node3D = $player
@onready var mob_spawn_path: PathFollow3D = $SpawnPath/SpawnLocation
@onready var weapon_spawn_path: PathFollow3D = $WeaponSpawnPath/WeaponSpawnLocation

var mob_timer: Timer
var weapon_timer: Timer


func _ready() -> void:
	mob_timer = create_timer(spawn_interval_mob, _on_mob_timer_timeout)
	weapon_timer = create_timer(spawn_interval_weapon, _on_weapon_timer_timeout)


func create_timer(interval: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(callback)
	return timer


func _on_mob_timer_timeout() -> void:
	if not mob_scene or not player:
		return
	
	var mob = mob_scene.instantiate()
	
	# Random spawn point along path
	mob_spawn_path.progress_ratio = randf()
	var spawn_pos = mob_spawn_path.position

	# Direction from spawn toward player
	var dir = (spawn_pos - player.position).normalized()
	dir.y = 0

	mob.look_at_from_position(spawn_pos, player.position, Vector3.UP)
	if mob.has_method("set_linear_velocity"):
		mob.set_linear_velocity(-dir * 60) # in case it's RigidBody3D
	elif "linear_velocity" in mob:
		mob.linear_velocity = -dir * 60
	
	add_child(mob)


func _on_weapon_timer_timeout() -> void:
	if weapon_scenes.is_empty():
		return
	
	var idx = randi() % weapon_scenes.size()
	var weapon_scene: PackedScene = weapon_scenes[idx]
	var weapon = weapon_scene.instantiate()


	weapon_spawn_path.progress_ratio = randf()
	var spawn_pos = weapon_spawn_path.global_position

	var wt = weapon.global_transform
	wt.origin = spawn_pos
	weapon.global_transform = wt
	
	add_child(weapon)
