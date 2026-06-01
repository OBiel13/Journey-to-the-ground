extends Node2D

func _ready() -> void:
	# Se o modo coop NÃO foi ativado no menu inicial
	if not Global.modo_coop:
		# Verifica se o Player2 está na fase e o deleta antes do jogo rodar
		if has_node("Player2"):
			get_node("Player2").queue_free()
