extends Area3D


signal start

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(camera: Camera3D, event: InputEvent, pos: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("start")
		start.emit()
		
