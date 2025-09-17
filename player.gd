extends CharacterBody3D
class_name Player

@export var SPEED = 20
@export var TURN_SPEED = 10
@export var MAX_CHARGE_TIME = 1.5 
@export var BASE_JUMP = 30.0
@export var MAX_JUMP = 70.0
@export var SHAKE_STRENGTH = 0.25
@export var FALL_TRESHOLD: float = 60

@onready var cam = $Camera3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var effect_anim: AnimationPlayer = $EffectPlayer
@onready var mesh: Node3D = $Pivot
@onready var explosion = $Particles
@onready var ragdoll = preload("res://ragdoll.tscn").instantiate()
@onready var death_screen = get_tree().root.get_node("Mainmenu/CanvasLayer/TextureRect")
@onready var flash_ui = get_tree().root.get_node("Mainmenu/CanvasLayer/ColorRect")

var charge_time: float = 0.0
var is_charging: bool = false
var original_position: Vector3
var is_shaking: bool = false
var previous_y_velocity: float = 0.0
var is_dead := false

func _ready() -> void:
	original_position = mesh.transform.origin

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 10
	
	previous_y_velocity = velocity.y
	
	# --- Jump charging ---
	if is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			# Start charging
			if not is_charging:
				is_charging = true
				_play_effect_anim_once("charge")
				start_shake()
			charge_time = min(charge_time + delta, MAX_CHARGE_TIME)

		elif Input.is_action_just_released("ui_accept") and is_charging:
			_play_effect_anim_once("RESET")
			var t = charge_time / MAX_CHARGE_TIME
			var jump_force = lerp(BASE_JUMP, MAX_JUMP, t)
			velocity.y = jump_force

			# Reset charging state
			is_charging = false
			charge_time = 0.0
			stop_shake()
			_play_anim("jump")
	else:
		is_charging = false
		charge_time = 0.0
		stop_shake()

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if direction != Vector3.ZERO:
		var target_basis = Basis.looking_at(direction)
		mesh.basis = mesh.basis.slerp(target_basis, TURN_SPEED * delta)

	move_and_slide()

	if not is_on_floor():
		pass # keep jump anim
	elif direction != Vector3.ZERO and not is_charging:
		_play_anim("walk")
	elif not is_charging:
		anim.stop() 

	if is_shaking:
		mesh.transform.origin = original_position + Vector3(
			randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH),
			randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH),
			randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH)
		)
	else:
		mesh.transform.origin = original_position
	
	if is_on_floor() and previous_y_velocity < -FALL_TRESHOLD:
		explosion.emitting = true
		explosion.restart()


func _play_anim(name: String) -> void:
	if anim.current_animation != name or not anim.is_playing():
		anim.play(name)


func _play_effect_anim_once(name: String) -> void:
	if effect_anim.current_animation != name or not effect_anim.is_playing():
		effect_anim.play(name, 0.0, 1.0, false)

func start_shake():
	is_shaking = true

func stop_shake():
	is_shaking = false
	mesh.transform.origin = original_position

func on_hit(attack: Attack):
	mesh.visible = false
	
	var hurtbox = $Hurtbox/CollisionShape3D
	var hitbox = $Hitbox/CollisionShape3D

	hurtbox.disabled = true
	hitbox.disabled = true
	
	var _ragdoll = ragdoll.duplicate(true)
	var dir = (global_transform.origin - attack.position).normalized()
	add_child(_ragdoll)
	_ragdoll.apply_central_impulse(dir * 80 + Vector3.UP * 95.0)
	_ragdoll.add_to_group("ragdoll") 
	var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_ragdoll.apply_torque_impulse(spin_axis * 50.0)
	cam.shake(0.1, 3)
	
	is_dead = true
	
	await get_tree().create_timer(2).timeout
	death_screen.show_deathscreen()
	flash_ui.flash(3600, Color.BLACK, 0.6)
