extends Position2D

signal shoot

export (PackedScene) var Bullet
export (float) var fire_rate = 0.22
export (float) var offset_x = 12

var can_shoot = true
var dir = 1

func _ready():
	$GunTimer.wait_time = fire_rate
	
func _process(delta):
	get_input()
	
func get_input():
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
func shoot():
	emit_signal("shoot", Bullet, Vector2.ZERO)
	can_shoot = false
	$GunTimer.start()
	print_debug(dir)

func _on_Muzzle_shoot(bullet, pos):
	var b = bullet.instance()
	b.start(pos, dir)
	add_child(b)


func _on_GunTimer_timeout():
	can_shoot = true


func _on_player_flip(side):
	if side != dir:
		position.x = offset_x * side
		print_debug(position.x)
		dir = side
