extends KinematicBody2D

export (int) var speed
var velocity = Vector2()

func start(pos, dir):
	position = pos
	velocity = Vector2(speed * dir, 0 )
	
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.is_in_group('walls'):
			queue_free()
	

