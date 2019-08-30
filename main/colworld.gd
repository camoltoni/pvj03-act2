
extends Node2D
#escena principal del nivel, administra condiciones del juego

var spawn_point = Vector2()

func _ready():
	#no es el mejor modo, puede obtener una referencia directamente
	var player_group = get_tree().get_nodes_in_group("player")
	if player_group.size()>0:
		spawn_point = player_group[0].global_position
		player_group[0].connect("im_dead",self,"_on_player_dead")
	
	for c in $comments.get_children():
		c.hide()
	

func _on_player_dead(): 
	#no es el mejor modo, se puede tener una referencia a la escena player en su lugar
	var Player_scene = load("res://characters/player/player.tscn")
	var player = Player_scene.instance() #null checks antes de esto
	player.position = spawn_point 
	add_child(player)
	player.connect("im_dead",self,"_on_player_dead")

func _on_princess_body_enter(body):
	# The name of this editor-generated callback is unfortunate
	if body.is_in_group("player"):
		$youwin.show()

