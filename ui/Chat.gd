extends VBoxContainer


const MESSAGE = preload("res://ui/Message.tscn")

onready var List = $Scroll/List
onready var MessageLine = $MessageLine


remotesync func add_message(author, message):
	var msg = MESSAGE.instance()
	msg.text = "%s: %s" % [author, message]
	List.add_child(msg)


func _on_text_entered(new_text):
	MessageLine.text = ""
	rpc("add_message", Network.player_name, new_text)
