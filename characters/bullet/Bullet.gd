extends Area2D

export (int) var speed
var velocity = Vector2()

func start(pos, degrees):
	position = pos
	rotation_degrees = degrees
	velocity = Vector2(speed, 0).rotated(deg2rad(degrees))
	
func _process(delta):
	position += velocity * delta
	


func _on_Bullet_body_entered(body):
	print_debug(body)
