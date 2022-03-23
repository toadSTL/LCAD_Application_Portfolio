extends Node

var z_index = 1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var scene_items = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():

	print(scene_items.size())
	for i in range(scene_items.size()):
		get_child(i).set_collectable_id(i)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
