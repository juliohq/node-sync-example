extends Control


const PLAYER_COUNT_FMT = "%d/%d"

onready var Waiting = $Center/Box/Waiting
onready var PlayerCount = $Center/Box/PlayerCount
onready var Join = $Center/Box/Join
onready var Host = $Center/Box/Host
onready var Start = $Center/Box/Start
onready var Cancel = $Center/Box/Cancel
onready var JoinTimeout = $JoinTimeout


func _ready():
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connection_failed", self, "_on_connection_failed")


remotesync func start_game():
	print("Game started")
	Events.emit_signal("game_started")


func _enable_buttons():
	Join.disabled = false
	Host.disabled = false


func _disable_buttons():
	Join.disabled = true
	Host.disabled = true


func join():
	_disable_buttons()
	if Network.join() == OK:
		JoinTimeout.start()


func host():
	_disable_buttons()
	if Network.host() == OK:
		get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
		get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
		
		Waiting.show()
		PlayerCount.show()
		PlayerCount.text = PLAYER_COUNT_FMT % [get_tree().get_network_connected_peers().size() + 1, Network.MAX_CLIENTS]
		Cancel.show()


func _on_connected_to_server():
	print("Connected to server successfully")


func _on_connection_failed():
	_enable_buttons()
	print("Connection failed")


func _on_server_disconnected():
	Network.terminate()
	_enable_buttons()
	print("Server disconnected")


func _on_JoinTimeout_timeout():
	if is_instance_valid(get_tree().network_peer) and get_tree().network_peer.get_connection_status() == get_tree().network_peer.CONNECTION_CONNECTING:
		print("Couldn't join server")
		get_tree().network_peer = null
		_enable_buttons()


# Signal only connected for server
func _on_network_peer_connected(id):
	var peers = get_tree().get_network_connected_peers()
	if not peers.empty():
		Start.show()
	
	PlayerCount.text = PLAYER_COUNT_FMT % [get_tree().get_network_connected_peers().size() + 1, Network.MAX_CLIENTS]


# Signal only connected for server
func _on_network_peer_disconnected(id):
	var peers = get_tree().get_network_connected_peers()
	if peers.empty():
		Start.hide()
	
	PlayerCount.text = PLAYER_COUNT_FMT % [get_tree().get_network_connected_peers().size() + 1, Network.MAX_CLIENTS]


func _on_Start_pressed():
	rpc("start_game")


func _on_Cancel_pressed():
	if Network.terminate():
		get_tree().disconnect("network_peer_connected", self, "_on_network_peer_connected")
		get_tree().disconnect("network_peer_disconnected", self, "_on_network_peer_disconnected")
		
		Waiting.hide()
		PlayerCount.hide()
		Start.hide()
		Cancel.hide()
		_enable_buttons()
		print("Server closed by host")
