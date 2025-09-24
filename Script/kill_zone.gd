extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		var attack = Attack.new()
		attack.position = Vector3.DOWN
		body.on_hit(attack)
