tool
#modo tool, el codigo se ejecutara en el editor
extends KinematicBody2D
signal flip
# This demo shows how to build a kinematic controller.

# Member variables

#Las dejé en mayúsculas pero son variables
#Aunque su uso interno es constante, discutible
export(float) var GRAVITY = 500.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
export(float) var FLOOR_ANGLE_TOLERANCE = 40
export(float) var WALK_FORCE = 600
export(float) var WALK_MIN_SPEED = 10
export(float) var WALK_MAX_SPEED = 200
export(float) var STOP_FORCE = 1300
export(float) var JUMP_SPEED = 200 setget _set_jump_speed
export(float) var JUMP_MAX_AIRBORNE_TIME = 0.2

export(float) var  SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
export(float) var  SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

#son variables necesarias para la lógica, no conviene exponerlas
var velocity = Vector2()
var on_air_time = 100
var jumping = false

var jump_curve = PoolVector2Array()

#Se puede seleccionar la escena que representa la explosión
export(PackedScene) var Explosion
var boom

signal im_dead

func _ready():
	if Engine.editor_hint: #para que haga draw sólo en tool mode
		jump_curve.resize(5)
		calculate_jump_curve()
		update()
	else:
		if Explosion != null:
			boom = Explosion.instance()

func _physics_process(delta): 
	#para que no procese lógica de juego en tool mode
	if Engine.editor_hint: 
		#de ser necesario se puede agregar lógica de editor
		return
	
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	
	var stop = true
	
	if (walk_left):
		emit_signal("flip", -1)
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif (walk_right):
		emit_signal("flip", 1)
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
	
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta
	
	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		on_air_time = 0
	
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta

func explode():
	if Explosion != null: #null check contra la PackedScene
		var boom = Explosion.instance()
		if boom is Node2D: #no puedo set_pos si no extiende Node2D  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			boom.position = global_position
			get_tree().current_scene.add_child(boom)
	emit_signal("im_dead")
	queue_free()

func _set_jump_speed(js):
	JUMP_SPEED = js
	calculate_jump_curve()
	update()
	

#maxima parabola dada por un salto
func calculate_jump_curve():
	var t = 2*JUMP_SPEED/GRAVITY
	
	for i in range(0,jump_curve.size()):
		var current_time = t / jump_curve.size() * (i+1)
		jump_curve[i].x = WALK_MAX_SPEED/jump_curve.size() * (i+1) #aprox
		jump_curve[i].y = -(JUMP_SPEED*current_time-pow(current_time,2)*GRAVITY/2)

func _draw():
	if Engine.editor_hint:
		#velocidad del salto, puede ser mas util mostrar la altura maxima
		draw_line(Vector2(),Vector2(0,-JUMP_SPEED*0.2),Color(1,0,0),3)
		#fuerza de caminar, en escala arbitraria para referencia
		draw_line(Vector2(),Vector2(WALK_FORCE*0.05,0),Color(0,1,0),3)
		#angulo del piso soportado
		draw_line(Vector2(),Vector2(30, 0).rotated(deg2rad(FLOOR_ANGLE_TOLERANCE-45)),Color(0,0,1),3)
		#parabola del salto
		for point in jump_curve:
			draw_circle(point,3,Color.violet)

