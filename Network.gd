extends Node


const SERVER_IP = "localhost"
const SERVER_PORT = 8000
const MAX_CLIENTS = 32


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	
	Events.connect("game_finished", self, "terminate")


func join():
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(Network.SERVER_IP, Network.SERVER_PORT)
	if err == OK:
		get_tree().network_peer = peer
	return err


func host():
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(Network.SERVER_PORT)
	if err == OK:
		print("Created server successfully")
		get_tree().network_peer = peer
	else:
		prints("Error creating server:", err)
	return err


func terminate():
	var is_network_peer = is_instance_valid(get_tree().network_peer)
	if is_network_peer:
		yield(get_tree(), "idle_frame")
		get_tree().network_peer = null
	return is_network_peer


func _exit_tree():
	if terminate():
		print("Terminating network feature...")


func _on_network_peer_connected(id):
	print("Peer %d connected" % id)


func _on_network_peer_disconnected(id):
	print("Peer %d disconnected" % id)
