extends CenterContainer


onready var Edit = $Base/Margin/Box/Name/Edit


func _ready():
	Edit.text = Network.player_name


func accept(player_name = Edit.text):
	Network.player_name = player_name
	queue_free()
