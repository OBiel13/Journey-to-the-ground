extends Camera2D

@export_category("Configurações da Câmera")
@export var min_zoom: float = 1.2  # Zoom de quando eles estão colados (maior = mais perto)
@export var max_zoom: float = 0.7  # Limite de afastamento para não ver a fase toda (menor = mais longe)
@export var velocidade_zoom: float = 3.0
@export var margem: float = 300.0  # Margem extra de visão ao redor dos players

var players: Array[Node] = []

func _process(delta: float) -> void:
	# Busca os jogadores vivos na tela
	players = get_tree().get_nodes_in_group("players")
	
	if players.size() == 0:
		return # Se todo mundo morrer, a câmera para
		
	# 1. CALCULA O CENTRO (Para onde a câmera vai)
	var centro = Vector2.ZERO
	for p in players:
		centro += p.global_position
	centro /= players.size()
	
	global_position = centro
	
	# 2. CALCULA O ZOOM DINÂMICO
	if players.size() > 1:
		# Descobre a distância entre o jogador mais longe e o mais perto
		var retangulo = Rect2(players[0].global_position, Vector2.ZERO)
		for p in players:
			retangulo = retangulo.expand(p.global_position)
			
		var tamanho_necessario = retangulo.size.length() + margem
		
		# Pega a resolução base do jogo e divide pelo tamanho que os players estão ocupando
		var resolucao_tela = get_viewport_rect().size.length()
		var zoom_alvo = resolucao_tela / tamanho_necessario
		
		# O clamp garante que o zoom nunca passe dos limites que você configurou no Inspetor
		zoom_alvo = clamp(zoom_alvo, max_zoom, min_zoom)
		
		# Aplica o zoom suavemente
		zoom = zoom.lerp(Vector2(zoom_alvo, zoom_alvo), velocidade_zoom * delta)
	else:
		# Se estiver jogando sozinho, volta pro zoom padrão
		zoom = zoom.lerp(Vector2(min_zoom, min_zoom), velocidade_zoom * delta)
