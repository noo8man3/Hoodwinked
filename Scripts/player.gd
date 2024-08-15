extends CharacterBody2D

var firebolt = preload("res://Scenes/firebolt.tscn")

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var cast_marker : Marker2D = $CastPoint
@onready var respawn_timer = $RespawnTimer
@onready var hit_flash_player = $HitFlashPlayer


const GRAVITY := 980
const SPEED := 250
const JUMP_HEIGHT := -300
const JUMP_LENGTH := 100

enum State { Idle, Run, Jump, Attack, Dying }
var current_state : State

var cast_point : float
var can_attack : bool = true
var is_jumping : bool
var is_attacking : bool
var is_dying : bool
var attack_timer_triggered : bool
var respawn_timer_triggered : bool


func _ready():
	current_state = State.Idle
	cast_point = cast_marker.position.x
	HealthManager.current_health = HealthManager.max_health


func _physics_process(delta):
	
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_melee(delta)
	player_casting(delta)
	player_dying(delta)
	
	move_and_slide()
	set_player_anims()
	#debug_print_state()


func debug_print_state():
	print(str(State.keys()[current_state]))


func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(delta):
	if is_on_floor() and !is_dying:
		current_state = State.Idle
		is_jumping = false


func player_run(delta):
	var direction = get_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction != 0 and is_on_floor():
		current_state = State.Run
		sprite.flip_h = false if direction > 0 else true


func player_jump(delta):
	if Input.is_action_just_pressed("jump") and !is_jumping:
		velocity.y = JUMP_HEIGHT
		current_state = State.Jump
		is_jumping = true
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = get_direction()
		velocity.x += direction * JUMP_LENGTH * delta


func player_melee(delta):
	var direction = get_direction()
	
	if Input.is_action_just_pressed("melee"):
		current_state = State.Attack
		is_attacking = true


func player_casting(delta):
	var direction = get_direction()
	
	if Input.is_action_just_pressed("cast"):
		var firebolt_instance = firebolt.instantiate()
		firebolt_instance.direction = get_sprite_direction()
		firebolt_instance.global_position = cast_marker.global_position
		get_parent().add_child(firebolt_instance)


func player_dying(delta):
	if HealthManager.current_health > 0:
		return
	else:
		current_state = State.Dying
		is_dying = true
		


func set_player_anims():
	if current_state == State.Idle and !is_attacking and !is_dying:
		sprite.play("idle")
	elif current_state == State.Run and !is_attacking and !is_dying:
		sprite.play("run")
	elif current_state == State.Jump and !is_dying:
		sprite.play("jump")
	elif current_state == State.Attack and !is_dying:
		sprite.play("attack")
		can_attack = false
		attack_timer.start()
	elif current_state == State.Dying:
		sprite.play("death")
		
		if(!respawn_timer_triggered):
			respawn_timer.start()
			respawn_timer_triggered = true
		
	else:
		current_state = State.Idle


func get_direction() -> int:
	var direction : int = Input.get_axis("left", "right")
	return direction


func get_sprite_direction() -> int:
	if !sprite.flip_h:
		return 1
	else:
		return -1


func _on_attack_timer_timeout():
	can_attack = true
	is_attacking = false


func _on_hitbox_body_entered(body):
	print(body.to_string())
	
	if body.is_in_group("Enemy"):
		HealthManager.decrease_health(body.damage_amount)
		hit_flash_player.play("hit_flash")
	elif body.is_in_group("Trap"):
		HealthManager.decrease_health(body.damage_amount)
		hit_flash_player.play("hit_flash")


func _on_hitbox_area_entered(area):
	print(area.to_string())
	print(area.name)
	
	if area.is_in_group("Abyss"):
		HealthManager.decrease_health(3)
	elif area.name == "hexbolt":
		HealthManager.decrease_health(1)
		hit_flash_player.play("hit_flash")


func _on_respawn_timer_timeout():
	get_tree().reload_current_scene()
