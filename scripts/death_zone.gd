extends Area2D

func _ready() -> void:
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Se o corpo que encostou estiver no grupo de players e tiver a função de morrer
	if body.is_in_group("players") and body.has_method("die"):
		body.die()
