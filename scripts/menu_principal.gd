extends Control

@export var cena_fase_1: PackedScene

func _ready() -> void:
	# Conecta os três botões
	$VBoxContainer/BotaoSolo.pressed.connect(_on_botao_solo_pressed)
	$VBoxContainer/BotaoCoop.pressed.connect(_on_botao_coop_pressed)
	$VBoxContainer/BotaoSair.pressed.connect(_on_botao_sair_pressed)

func _on_botao_solo_pressed() -> void:
	Global.modo_coop = false
	carregar_jogo()

func _on_botao_coop_pressed() -> void:
	Global.modo_coop = true
	carregar_jogo()

func carregar_jogo() -> void:
	if cena_fase_1:
		get_tree().change_scene_to_packed(cena_fase_1)
	else:
		get_tree().change_scene_to_file("res://scenes/mapa_fase_1.tscn")

func _on_botao_sair_pressed() -> void:
	get_tree().quit()
