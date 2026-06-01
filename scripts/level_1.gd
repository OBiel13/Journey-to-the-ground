extends Node2D

func _ready() -> void:
	# Se o modo coop NÃO foi ativado no menu
	if not Global.modo_coop:
		# Verifica se o Player2 está na cena e o deleta antes do jogo começar
		if has_node("Player2"):
			get_node("Player2").queue_free()
