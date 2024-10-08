extends Area2D

@export var speed = 500
var direction : int
@onready var sprite = $Sprite2D

func _ready():
	if direction == -1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta):
	move_local_x(direction * speed * delta)

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.is_dying = true
		self.queue_free()
	elif body.name == "TileMap":
		self.queue_free()
