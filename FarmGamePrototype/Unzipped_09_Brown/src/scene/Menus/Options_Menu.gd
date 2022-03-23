extends Control
onready var ui = get_parent()

func _ready():
	pass

func _on_Accept_pressed():
	get_tree().paused = false
	ui.set("inv_accessible", true)
	visible = false

func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_Toggle_Debug_Disp_Button_pressed():
	pass # Replace with function body.


func _on_Debug_Disp_pressed():
	if not ui.get("debug_stats_layer") == null:
		ui.debug_stats_layer.visible = !ui.debug_stats_layer.visible
	else:
		print("Error: no debug layer to display")
