extends Node


func _ready():
	if get_tree().is_network_server():
		get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")


func _on_network_peer_disconnected(id):
	if get_tree().get_network_connected_peers().empty():
		print("Finishing server, there are no more peers")
		Events.emit_signal("game_finished")
