extends CharacterBody2D

@export var limite_velocidade_queda: float = 750.0 
var velocidade_maxima_atingida: float = 0.0

# === CONFIGURAÇÃO DE CO-OP HÍBRIDO ===
@export_category("Configuração de Input")
@export var usa_teclado: bool = true
@export var dispositivo_controle_id: int = 0

# --- VARIÁVEIS BASE ---
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 2000.0

# --- VARIÁVEIS DO DASH ---
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
var is_dashing: bool = false
var dash_timer: float = 0.0
var can_dash: bool = true
var last_facing_direction: float = 1.0

# --- VARIÁVEIS DO COYOTE TIME ---
@export var coyote_time: float = 0.15
var coyote_timer: float = 0.0

# --- VARIÁVEIS DO GANCHO ---
@export var max_hook_range: float = 400.0
@export var rope_climb_speed: float = 200.0
var is_hooked: bool = false
var hook_anchor_pos: Vector2 = Vector2.ZERO
var current_rope_length: float = 0.0

# --- VARIÁVEIS DE MIRA ---
@export var reticle_distance: float = 100.0

# --- CONTROLE DE ESTADO DOS BOTÕES ---
var btn_jump_anterior: bool = false
var btn_hook_anterior: bool = false
var btn_dash_anterior: bool = false
var btn_release_anterior: bool = false

# --- CONTROLE DE ANIMAÇÃO DE MORTE ---
var is_dying: bool = false

@onready var hook_ray: RayCast2D = $HookRay
@onready var hook_line: Line2D = $HookLine
@onready var reticle: Sprite2D = $Reticle
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	hook_line.clear_points()
	hook_line.add_point(Vector2.ZERO)
	hook_line.add_point(Vector2.ZERO)
	hook_line.visible = false

	# === NASCIMENTO E CHECKPOINT SEGURO ===
	if Global.checkpoint_atual != Vector2.ZERO:
		# Se for o Player 1 (Teclado), nasce 15 pixels para a esquerda (-15)
		# Se for o Player 2 (Controle), nasce 15 pixels para a direita (+15)
		var deslocamento_x = -15.0 if usa_teclado else 15.0
		
		# Aplica a posição do checkpoint + o deslocamento horizontal
		global_position = Global.checkpoint_atual + Vector2(deslocamento_x, 0)

func _physics_process(delta: float) -> void:
	# Trava física se o personagem estiver morrendo
	if is_dying:
		velocity.y += gravity * delta
		move_and_slide()
		return

	# === 1. CONTROLE DE CHÃO E MORTE POR QUEDA ===
	if is_on_floor():
		if velocidade_maxima_atingida > limite_velocidade_queda:
			die()
			return 
			
		can_dash = true
		coyote_timer = coyote_time
		velocidade_maxima_atingida = 0.0 
	else:
		coyote_timer -= delta
		
		if velocity.y > 0 and not is_hooked and not is_dashing:
			if velocity.y > velocidade_maxima_atingida:
				velocidade_maxima_atingida = velocity.y

	if is_hooked or is_dashing:
		velocidade_maxima_atingida = 0.0

	# === 2. DIREÇÃO HORIZONTAL ===
	var direction: float = 0.0
	if usa_teclado:
		direction = Input.get_axis("left", "right")
	else:
		direction = Input.get_joy_axis(dispositivo_controle_id, JOY_AXIS_LEFT_X)
		if abs(direction) < 0.2: direction = 0.0

	# Controle visual do espelhamento do Sprite
	if direction != 0:
		last_facing_direction = sign(direction)
		animated_sprite.flip_h = (direction < 0)

	# === 3. MIRA DO GANCHO ===
	var aim_direction := Vector2.ZERO
	if usa_teclado:
		aim_direction = global_position.direction_to(get_global_mouse_position())
		reticle.global_position = get_global_mouse_position()
	else:
		var joy_x = Input.get_joy_axis(dispositivo_controle_id, JOY_AXIS_RIGHT_X)
		var joy_y = Input.get_joy_axis(dispositivo_controle_id, JOY_AXIS_RIGHT_Y)
		var stick = Vector2(joy_x, joy_y)
		
		if stick.length() > 0.2:
			aim_direction = stick.normalized()
		else:
			aim_direction = Vector2(last_facing_direction, 0)
		reticle.position = aim_direction * reticle_distance

	reticle.visible = not is_hooked and not is_dashing

	# === 4. MAPEAMENTO SEGURO DE BOTÕES ===
	var acabou_de_pular: bool = false
	var segurando_subir_descer: float = 0.0
	var soltou_gancho: bool = false
	var tentou_gancho: bool = false
	var tentou_dash: bool = false

	if usa_teclado:
		acabou_de_pular = Input.is_action_just_pressed("jump")
		segurando_subir_descer = Input.get_axis("up", "down")
		soltou_gancho = Input.is_action_just_pressed("release_hook")
		tentou_gancho = Input.is_action_just_pressed("hook")
		tentou_dash = Input.is_action_just_pressed("dash")
	else:
		segurando_subir_descer = Input.get_joy_axis(dispositivo_controle_id, JOY_AXIS_LEFT_Y)
		if abs(segurando_subir_descer) < 0.2: segurando_subir_descer = 0.0
		
		var pular_agora = Input.is_joy_button_pressed(dispositivo_controle_id, JOY_BUTTON_A)
		acabou_de_pular = pular_agora and not btn_jump_anterior
		btn_jump_anterior = pular_agora

		var gancho_agora = Input.is_joy_button_pressed(dispositivo_controle_id, JOY_BUTTON_RIGHT_SHOULDER)
		tentou_gancho = gancho_agora and not btn_hook_anterior
		btn_hook_anterior = gancho_agora

		var dash_agora = Input.is_joy_button_pressed(dispositivo_controle_id, JOY_BUTTON_LEFT_SHOULDER)
		tentou_dash = dash_agora and not btn_dash_anterior
		btn_dash_anterior = dash_agora

		var soltou_agora = Input.is_joy_button_pressed(dispositivo_controle_id, JOY_BUTTON_B)
		soltou_gancho = soltou_agora and not btn_release_anterior
		btn_release_anterior = soltou_agora

	# === 5. MÁQUINA DE ESTADOS E FÍSICA ===
	if tentou_gancho and not is_hooked and not is_dashing:
		hook_ray.target_position = aim_direction.normalized() * max_hook_range
		hook_ray.force_raycast_update()

		if hook_ray.is_colliding():
			is_hooked = true
			hook_anchor_pos = hook_ray.get_collision_point()
			current_rope_length = global_position.distance_to(hook_anchor_pos)

	if tentou_dash and can_dash and not is_hooked and not is_dashing:
		is_dashing = true
		can_dash = false
		dash_timer = dash_duration
		Global.total_dashes += 1

	if is_hooked:
		# === ANIMAÇÃO: PENDURADO ===
		animated_sprite.play("is_hooked")
		
		hook_line.visible = true
		hook_line.set_point_position(0, Vector2.ZERO)
		hook_line.set_point_position(1, to_local(hook_anchor_pos))

		if segurando_subir_descer != 0:
			current_rope_length += segurando_subir_descer * rope_climb_speed * delta
			current_rope_length = clamp(current_rope_length, 20.0, max_hook_range)

		velocity.y += gravity * delta
		if direction != 0:
			velocity.x += direction * (speed / 2) * delta

		move_and_slide()

		var dist_to_anchor = global_position.distance_to(hook_anchor_pos)
		if dist_to_anchor > current_rope_length:
			var rope_dir = hook_anchor_pos.direction_to(global_position)
			global_position = hook_anchor_pos + rope_dir * current_rope_length
			velocity = velocity.slide(-rope_dir)

		if acabou_de_pular:
			is_hooked = false
			velocity.y = jump_velocity
			can_dash = true
		elif soltou_gancho:
			is_hooked = false

	elif is_dashing:
		# === ANIMAÇÃO: DASH ===
		animated_sprite.play("dash")
		
		hook_line.visible = false
		dash_timer -= delta
		velocity.x = last_facing_direction * dash_speed
		velocity.y = 0
		
		if dash_timer <= 0:
			is_dashing = false
			
		move_and_slide()
			
	else:
		hook_line.visible = false
		if not is_on_floor():
			velocity.y += gravity * delta
			
			# === ANIMAÇÃO: PULO E QUEDA ===
			if velocity.y < 0:
				animated_sprite.play("jump")
			else:
				animated_sprite.play("fall")
		else:
			# === ANIMAÇÃO: PARADO E CORRENDO ===
			if direction != 0:
				animated_sprite.play("walk")
			else:
				animated_sprite.play("idle")

		if acabou_de_pular and coyote_timer > 0.0:
			velocity.y = jump_velocity
			coyote_timer = 0.0

		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

		move_and_slide()
		
func die() -> void:
	# Verifica se já está morto para não repetir a função
	if is_dying: return
	
	is_dying = true
	Global.total_mortes += 1
	Global.salvar_dados_ml()
	
	# Corta todo o movimento e velocidade
	velocity = Vector2.ZERO
	is_hooked = false
	is_dashing = false
	hook_line.visible = false
	
	# Toca a animação e espera ela terminar antes de recarregar a cena
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	
	get_tree().reload_current_scene()
