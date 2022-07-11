extends Node


const PLAYER = preload("res://characters/Player.tscn")
const VIEW = preload("res://world/View.tscn")

var players_done = []

onready var Sort = $Sort


func _ready():
	if get_tree().is_network_server():
		rpc("pre_configure_game")


remotesync func pre_configure_game():
	get_tree().paused = true
	
	var id = get_tree().get_network_unique_id()
	
	# Spawn my player
	var my_player = PLAYER.instance()
	my_player.name = str(id)
	my_player.set_network_master(id)
	my_player.player_name = Network.player_name
	Sort.add_child(my_player)
	var view = VIEW.instance()
	my_player.call_deferred("add_child", view)
	
	# Spawning other players
	for player in Network.player_info.keys():
		var p = PLAYER.instance()
		p.name = str(player)
		p.set_network_master(player)
		p.player_name = Network.player_info[player]
		Sort.add_child(p)
	
	if not get_tree().is_network_server():
		rpc_id(1, "done_preconfiguring")


remote func done_preconfiguring():
	var who = get_tree().get_rpc_sender_id()
	
	if not who in players_done:
		players_done.append(who)
	
	if players_done.size() == Network.player_info.size():
		rpc("post_configure_game")


remotesync func post_configure_game():
	if get_tree().get_rpc_sender_id() == 1:
		get_tree().paused = false
