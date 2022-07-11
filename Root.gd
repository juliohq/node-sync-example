extends Node


const LEVEL = preload("res://levels/Level.tscn")
const LOBBY = preload("res://lobby/Lobby.tscn")

onready var Current = $Lobby


func _ready():
	Events.connect("game_started", self, "replace_current", [LEVEL])
	Events.connect("game_finished", self, "replace_current", [LOBBY])


func replace_current(new):
	if is_instance_valid(Current):
		Current.queue_free()
	Current = new.instance()
	add_child(Current)
