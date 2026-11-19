extends CharacterBody3D
## First-person player controller: WASD movement, mouse look, jump, sprint,
## and a forward interaction ray used to talk to NPCs and pick up clues.

@export var walk_speed: float = 3.2
@export var sprint_speed: float = 5.6
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var interact_range: float = 2.5

const GRAVITY: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var _current_interactable: Node = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.input_locked:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	if event.is_action_pressed("interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	if GameManager.input_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()
	_update_interact_prompt()


func _update_interact_prompt() -> void:
	var target := _get_interactable()
	if target == _current_interactable:
		return
	_current_interactable = target
	if target and target.has_method("get_interact_prompt"):
		UIManager.set_interact_prompt(target.get_interact_prompt())
	elif target:
		UIManager.set_interact_prompt("Interact")
	else:
		UIManager.set_interact_prompt("")


func _try_interact() -> void:
	var target := _get_interactable()
	if target and target.has_method("interact"):
		target.interact(self)


func _get_interactable() -> Node:
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * interact_range
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider = result.get("collider")
	if collider and collider.is_in_group("interactable"):
		return collider
	return null
