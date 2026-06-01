extends Area2D

# Cria a lista de opções para o Dropdown (NONE = Parada)
enum MoveDirection { NONE, UP, DOWN, LEFT, RIGHT }

@export_category("Movement Settings")
@export var move_dir: MoveDirection = MoveDirection.NONE
@export var speed: float = 150.0
@export var distance: float = 150.0

var posicao_inicial: Vector2
var posicao_final: Vector2
var indo_para_o_fim: bool = true

func _ready() -> void:
	# Conecta o sinal de colisão com o Hurtbox do Player
	area_entered.connect(_on_area_entered)
	
	posicao_inicial = global_position
	
	# Descobre para qual lado a serra deve ir baseado na sua escolha do Dropdown
	var vetor_direcao: Vector2 = Vector2.ZERO
	
	match move_dir:
		MoveDirection.UP:
			vetor_direcao = Vector2(0, -1)
		MoveDirection.DOWN:
			vetor_direcao = Vector2(0, 1)
		MoveDirection.LEFT:
			vetor_direcao = Vector2(-1, 0)
		MoveDirection.RIGHT:
			vetor_direcao = Vector2(1, 0)
			
	# Calcula o ponto de destino exato multiplicando a direção pela distância
	posicao_final = posicao_inicial + (vetor_direcao * distance)

func _physics_process(delta: float) -> void:
	# A serra só ganha movimento se você não deixar no "NONE"
	if move_dir != MoveDirection.NONE and distance > 0:
		var alvo = posicao_final if indo_para_o_fim else posicao_inicial
		
		global_position = global_position.move_toward(alvo, speed * delta)
		
		if global_position.distance_to(alvo) < 1.0:
			indo_para_o_fim = not indo_para_o_fim

# Função de hit separada da física, usando a lógica do Hurtbox
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		var player = area.get_parent()
		if player.has_method("die"):
			player.die()
