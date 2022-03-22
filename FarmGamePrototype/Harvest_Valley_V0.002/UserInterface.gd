extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var map = get_node("../Map")
onready var player = map.get_player()
onready var debug_stats_layer = $Debug_Display

var inv_accessible: bool
var options_open: bool
var paused: bool

func _input(event):
	if event.is_action_pressed("inventory"):
		if(inv_accessible):
			$Inventory.initialize_inventory()
			$Inventory.visible = !$Inventory.visible
	if event.is_action_pressed("esc_menu"):
		if(paused && !options_open):
			get_tree().paused = false
			paused = false
		else:
			$Options_Menu.hide()
			options_open = false
			get_tree().paused = true
			paused = true
		$Escape_Menu.ready_menu()
		$Escape_Menu.visible = !$Escape_Menu.visible
		inv_accessible = !$Escape_Menu.visible
		$Inventory.visible = false
		#OS.window_fullscreen = !OS.window_fullscreen

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	options_open = false
	inv_accessible = true
	paused = false
	debug_stats_layer.add_stat("Player Position", player, "position", false)
	debug_stats_layer.add_stat("(X,Y) Velocity", player, "vel", false)
	debug_stats_layer.add_stat("(Z) Height", player, "z", false)
	debug_stats_layer.add_stat("Player Direction", player, "face_direction", false)
	#debug_stats_layer.add_stat("Items to Collect", map, "num_items", false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
