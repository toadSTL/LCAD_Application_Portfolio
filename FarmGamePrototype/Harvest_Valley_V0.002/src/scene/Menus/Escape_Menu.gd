extends Control

onready var ui = get_parent()
onready var options = get_node("../Options_Menu")
# Called when the node enters the scene tree for the first time.
func _ready():
	ready_menu()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	ui.set("inv_accessible", false)
	ui.set("options_open", true)
	options.visible = true
	visible = false

func _on_Resume_pressed():
	ui.set("inv_accessible", true)
	visible = false
	get_tree().paused = false

func ready_menu():
	$Menu_Buttons/Resume.grab_focus()
