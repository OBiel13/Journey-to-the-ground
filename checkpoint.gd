extends Area2D

# Pega a referência do sprite para podermos mudar a cor
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verifica com 100% de certeza se quem encostou é um dos jogadores
	if body.is_in_group("players"):
		# Salva a posição global da bandeira
		Global.checkpoint_atual = global_position
		
		# Muda a cor da bandeira para verde como feedback de "Salvo!"
		sprite.modulate = Color(0, 1, 0)
