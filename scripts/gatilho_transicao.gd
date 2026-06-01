extends Area2D

@export_category("Configuração de Transição")
@export var proxima_fase: PackedScene
@export var eh_fim_de_jogo: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if eh_fim_de_jogo:
			# Salva os dados de Machine Learning
			Global.salvar_dados_ml()
			
			# Chama a nossa interface customizada
			mostrar_tela_final()
		else:
			if proxima_fase:
				Global.checkpoint_atual = Vector2.ZERO 
				get_tree().change_scene_to_packed(proxima_fase)

func mostrar_tela_final() -> void:
	# Pausa toda a física e os personagens
	get_tree().paused = true
	
	# Cria um CanvasLayer dinâmico (fica por cima da Câmera)
	var canvas = CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS # Garante que a UI funcione com o jogo pausado
	
	# Fundo preto quase opaco
	var fundo = ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.9)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# O texto da tela de fim
	var texto = Label.new()
	texto.text = "FIM DA DEMO!\n\nDados da partida salvos com sucesso (dataset_jogador.csv).\n\nObrigado por jogar!\n\nPressione ESC para fechar ou recarregue a página na Web."
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Deixa a letra grande e legível
	texto.add_theme_font_size_override("font_size", 28)
	
	# Monta as peças e joga na tela
	fundo.add_child(texto)
	canvas.add_child(fundo)
	add_child(canvas)
