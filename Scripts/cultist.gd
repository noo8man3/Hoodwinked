extends CharacterBody2D

var hexbolt = preload("res://Scenes/hexbolt.tscn")

@export var patrol_points : Node
@export var speed = 2500
@export var wait_time = 2
@export var damage_amount : int = 1

@onready var cast_point = $CastPoint
@onready var sprite = $AnimatedSprite2D
@onready var cast_timer = $CastTimer
@onready var patrol_timer = $PatrolTimer
@onready var death_timer = $DeathTimer

const GRAVITY := 980

enum State { Active }

var current_state : State
var num_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var direction : Vector2 = Vector2.RIGHT
var current_point_position : int
var can_walk : bool
var is_dying : bool

func _ready():
	if patrol_points != null:
		num_points = patrol_points.get_children().size()
		
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
			
		current_point = point_positions[current_point_position]
	else:
		print("No points found")
	
	patrol_timer.wait_time = wait_time

func _physics_process(delta):
	enemy_gravity(delta)
	enemy_active(delta)
	enemy_dying(delta)
	
	move_and_slide()

func enemy_gravity(delta):
	velocity.y += GRAVITY * delta

func enemy_active(delta):
	if !can_walk:
		velocity.x = 0
		return
	
	if abs(position.x -current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Active
	else:
		current_point_position += 1
	
		if current_point_position >= num_points:
			current_point_position = 0
	
		current_point = point_positions[current_point_position]
	
		if current_point.x < position.x:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT
	
		can_walk = false
		patrol_timer.start()


func enemy_dying(delta):
	if !is_dying:
		return
	else:
		velocity.x = 0
		sprite.play("death")
		death_timer.start()
		is_dying = false


func _on_death_timer_timeout():
	self.queue_free()


func _on_patrol_timer_timeout():
	can_walk = true


func _on_cast_timer_timeout():
	var hexbolt_instance = hexbolt.instantiate()
	hexbolt_instance.global_position = cast_point.global_position
	hexbolt_instance.name = "hexbolt"
	get_parent().add_child(hexbolt_instance)
