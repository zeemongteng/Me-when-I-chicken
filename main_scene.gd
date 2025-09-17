extends Node3D

@export var mob_scene: PackedScene
@export var spawn_interval: float = 3.0 
@export var weapon_scenes: Array[PackedScene]

@onready var light = $DirectionalLight3D

var _spawn_timer: Timer

func _ready() -> void:
	# Create and configure timer
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.one_shot = false
	_spawn_timer.autostart = true
	add_child(_spawn_timer)

	# Connect the timeout signal
	_spawn_timer.timeout.connect(_on_mob_timer_timeout)

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $SpawnPath/SpawnLocation
	mob_spawn_location.progress_ratio = randf()

	var player_position = $player.position
	
	var dir = (mob_spawn_location.position - player_position).normalized()
	dir.y = 0
	
	mob.look_at_from_position(mob_spawn_location.position, dir, Vector3.UP)

	mob.linear_velocity = (-dir * 60)
	
	add_child(mob)

func spawn_weapon():
	var idx: int = randi() % weapon_scenes.size()
	var random_weapon_scene: PackedScene = weapon_scenes[idx]
	var weapon = random_weapon_scene.instantiate()

	var pf: PathFollow3D = $WeaponSpawnPath/WeaponSpawnLocation
	pf.progress_ratio = randf()
	var spawn_pos: Vector3 = pf.global_transform.origin
	var wt: Transform3D = weapon.global_transform
	wt.origin = spawn_pos
	weapon.global_transform = wt
	add_child(weapon)

func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_button_p"):
		spawn_weapon()
