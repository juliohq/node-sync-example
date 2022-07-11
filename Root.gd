extends Node


onready var Lobby = $Lobby


func _ready():
	Events.connect("game_started", self, "_on_game_started")
	Events.connect("game_finished", self, "_on_game_finished")


func _on_game_started():
	pass


func _on_game_finished():
	pass
