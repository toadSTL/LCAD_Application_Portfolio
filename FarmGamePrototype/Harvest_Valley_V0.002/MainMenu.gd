extends Control

#onready var options = get_node("Options_Menu")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("esc_menu"):
		$Options_Menu.hide()
		

func _on_Play_pressed():
	get_tree().change_scene("res://Demo_Scene.tscn")

func _on_Options_pressed():
	$Options_Menu.show()
	
func _on_Exit_pressed():
	get_tree().quit()



