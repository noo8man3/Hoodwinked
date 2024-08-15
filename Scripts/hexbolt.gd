extends Area2D

@export var damage_amount : int = 1
@export var speed = 300

@onready var sprite = $Sprite2D

func _physics_process(delta):
	move_local_x(1 * speed * delta)

func _on_area_entered(area):
	self.queue_free()


func _on_timer_timeout():
	self.queue_free()


func _on_body_entered(body):
	if body.name == "TileMap":
		queue_free()
