extends Area3D


signal start

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_camera: Camera3D, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("start")
		start.emit()
		
