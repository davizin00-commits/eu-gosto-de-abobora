extends CharacterBody2D

var velocidade = 90.0
var gravidade = 980.0
var dano = 1
var player = null
var pode_atacar = true
var esta_atacando = false
var distancia_ataque = 30

# --- Vida ---
var vida = 2  # <-- NOVO

# --- Patrulha ---
var direcao = -1
var distancia_patrulha = 100.0
var ponto_inicial : Vector2

@onready var sprite = $AnimatedSprite2D
@onready var area_dano = $Area2D

func _ready():
	ponto_inicial = global_position
	velocity.x = direcao * velocidade
	sprite.animation_finished.connect(_animacao_terminou)
	area_dano.body_entered.connect(_ao_encostar)

func receber_dano(dano_recebido):  # <-- NOVO
	vida -= dano_recebido
	print("Mendigo vida:", vida)
	if vida <= 0:
		queue_free()  # some do mapa

func _ao_encostar(corpo):
	if corpo.has_method("receber_dano") and pode_atacar:
		pode_atacar = false
		esta_atacando = true
		sprite.play("atacar")
		corpo.receber_dano(dano)
		if is_inside_tree():
			await get_tree().create_timer(1.0).timeout
		pode_atacar = true
		esta_atacando = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade * delta

	if player == null:
		player = get_tree().root.find_child("Player", true, false)

	if esta_atacando:
		velocity.x = 0
		return

	if player:
		var distancia = global_position.distance_to(player.global_position)
		if distancia <= distancia_ataque:
			velocity.x = 0
		else:
			_patrulhar()
	else:
		_patrulhar()

	move_and_slide()

func _patrulhar():
	sprite.play("andando")
	var distancia_do_inicio = global_position.x - ponto_inicial.x
	if distancia_do_inicio >= distancia_patrulha:
		direcao = -1
	elif distancia_do_inicio <= -distancia_patrulha:
		direcao = 1
	velocity.x = direcao * velocidade
	sprite.flip_h = direcao == 1

func _animacao_terminou():
	if sprite.animation == "atacar":
		sprite.play("andando")
