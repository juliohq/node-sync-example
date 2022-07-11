extends Sprite


var direction = Vector2()
var speed = 128.0

var player_name = ""

onready var Name = $Name


func _ready():
	set_physics_process(get_network_master() == get_tree().get_network_unique_id())
	set_process_input(get_network_master() == get_tree().get_network_unique_id())
	
	rset_config("global_position", MultiplayerAPI.RPC_MODE_PUPPET)
	
	Name.text = player_name


func _input(event):
	direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")


func _physics_process(delta):
	translate(direction * speed * delta)
	rset_unreliable("global_position", global_position)
