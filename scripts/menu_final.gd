extends Control

func _ready() -> void:
	$VBoxContainer/BotaoVoltarMenu.pressed.connect(_on_botao_voltar_menu_pressed)

func _on_botao_voltar_menu_pressed() -> void:
	# Volta para o menu principal
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
