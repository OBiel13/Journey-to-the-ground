extends Node

var modo_coop: bool = false

var checkpoint_atual: Vector2 = Vector2.ZERO

# ---MACHINE LEARNING (FEATURES) ---
var total_mortes: int = 0
var total_dashes: int = 0
var tempo_no_gancho: float = 0.0

# Prepara um arquivo CSV na pasta do jogo para salvar os dados
var caminho_arquivo: String = "user://dataset_jogador.csv"

func _ready() -> void:
	# Cria o cabeçalho do CSV se o arquivo não existir
	if not FileAccess.file_exists(caminho_arquivo):
		var arquivo = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
		arquivo.store_line("Mortes,Dashes,Tempo_Gancho_Segundos")
		arquivo.close()

# Função para salvar a "Sessão" no arquivo CSV
func salvar_dados_ml() -> void:
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ_WRITE)
	arquivo.seek_end() # Vai para o final do arquivo
	# Cria a linha com os dados atuais
	var linha = str(total_mortes) + "," + str(total_dashes) + "," + str(snapped(tempo_no_gancho, 0.01))
	arquivo.store_line(linha)
	arquivo.close()
	print("Dados exportados para o Dataset!")
