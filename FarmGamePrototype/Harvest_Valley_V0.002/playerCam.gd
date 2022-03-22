extends Camera2D

var player_height_vec = Vector2.ZERO
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("../Map/player")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	player_height_vec = player.z*Vector2.UP
	position = player.position+player_height_vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
