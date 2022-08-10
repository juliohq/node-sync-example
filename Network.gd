extends Node


signal player_registered(id, player_name)

const SERVER_IP = "localhost"
const SERVER_PORT = 8000
const MAX_CLIENTS = 32

var player_name = "player"
var player_info = {}


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	
	Events.connect("game_finished", self, "terminate")


func join(server_ip=SERVER_IP, server_port=SERVER_PORT):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(server_ip, server_port)
	if err == OK:
		get_tree().network_peer = peer
	else:
		print("Error joining server (%s:%d): %d", [server_ip, server_port, err])
	return err


func host(server_port=SERVER_PORT):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(server_port)
	if err == OK:
		print("Created server successfully")
		get_tree().network_peer = peer
	else:
		print("Error creating server with port %d: %d" % [server_port, err])
	return err


remote func register_player(player_name):
	var id = get_tree().get_rpc_sender_id()
	
	player_info[id] = player_name
	print("Registered player '%s' with id %d" % [player_name, id])
	
	emit_signal("player_registered", id, player_name)


func terminate():
	player_info.clear()
	
	var is_network_peer = is_instance_valid(get_tree().network_peer)
	if is_network_peer:
		yield(get_tree(), "idle_frame")
		get_tree().network_peer = null
	return is_network_peer


func _exit_tree():
	if terminate():
		print("Terminating network feature...")


func _on_player_connected(id):
	rpc_id(id, "register_player", player_name)
	
	print("Peer %d connected" % id)


func _on_player_disconnected(id):
	print("Unregistered player '%s' with id %d" % [player_info[id], id])
	player_info.erase(id)
