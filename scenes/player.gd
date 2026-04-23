extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -640.0
const GRAVIDADE = 980.0

var vida = 3
var pode_receber_dano = true
var esta_atacando = false

@onready var sprite = $AnimatedSprite2D
@onready var area_ataque = $Area2D

func _ready():
	sprite.play("andando")
	sprite.animation_finished.connect(_animacao_terminou)
	area_ataque.monitoring = false
	area_ataque.body_entered.connect(_ao_acertar_inimigo)  # <-- NOVO

func _ao_acertar_inimigo(corpo):  # <-- NOVO
	if corpo.has_method("receber_dano"):
		corpo.receber_dano(1)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		if not esta_atacando:
			sprite.play("pulo")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = FORCA_PULO

	if Input.is_action_just_pressed("Ataque_cacto") and not esta_atacando:
		atacar()

	var direcao = Input.get_axis("move_left", "move_right")

	if direcao:
		velocity.x = direcao * VELOCIDADE
		sprite.flip_h = (direcao < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	if is_on_floor() and not esta_atacando:
		sprite.play("andando")

	move_and_slide()

func atacar():
	esta_atacando = true
	sprite.play("atacar")
	area_ataque.monitoring = true

func _animacao_terminou():
	if sprite.animation == "atacar":
		esta_atacando = false
		area_ataque.monitoring = false
		sprite.play("andando")

func receber_dano(dano):
	if pode_receber_dano:
		pode_receber_dano = false
		vida -= dano
		print("Vida restante:", vida)
		if vida <= 0:
			morrer()
		else:
			await get_tree().create_timer(0.5).timeout
			pode_receber_dano = true

func morrer():
	print("morreu!")
	get_tree().call_deferred("reload_current_scene")
