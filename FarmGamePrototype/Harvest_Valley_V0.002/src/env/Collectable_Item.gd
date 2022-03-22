extends Area2D
class_name Collectable_Item

signal collectable_item_IE(item_event, col_item_name, item_id, item_qt)
signal quick_collect(col_item_name,item_id,item_qt)
var pick_up_range = 0.0
onready var player = get_node("../player")
var tex = ImageTexture.new()
var can_collect = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collectable_id = 0
export var item_name = ""
var item_qty = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#gravity_scale = 0.0
	#print(self.global_position)
	#set_item_texture()


func _physics_process(delta):
	if pick_up_range == 50 && can_collect:
		#var collision_list = get_colliding_bodies()
		#if collision_list.has(player):
		var player_pos = player.get_global_position()
		var my_pos = $Sprite.get_global_position()
		if player_pos.distance_to(my_pos) < pick_up_range:
			var pos_diff = player_pos-my_pos
			var dir_to_move = pos_diff.normalized()
			var vel = dir_to_move*100.00
			position += vel*delta
		if overlaps_body(player):
			var debug_print = str(item_name, ": sending signal" )
			print(debug_print)
			emit_signal("quick_collect", item_name, collectable_id, item_qty)
				

func _input(event):
	pass
			#self.position += (player_pos.get_origin()-event.position) + hand_display_vec
			#print("and here")
			#print(self.z_index)
	
func initialize_item(nm: String, id: int, qt: int, rg: float):
	set_item_name(nm)
	set_collectable_id(id)
	set_item_qty(qt)
	set_pick_up_range(rg)
	set_item_texture_and_geometry()

func set_item_name(new_name: String):
	item_name = new_name
	
func set_collectable_id(new_id: int):
	collectable_id = new_id

func set_item_qty(new_qty: int):
	item_qty = new_qty
	
func set_pick_up_range(new_range: float):
	pick_up_range = new_range

func set_item_texture_and_geometry():
	$Sprite.texture = load("res://assets/obj/obj_icon/"+JsonData.item_data[item_name]["FileName"])
	var s = $Sprite.texture.get_size()
	var x_scale = s.x*0.45
	var y_scale = s.y*0.45
	$CollisionShape2D.scale = Vector2(x_scale,y_scale)
	
func set_collectable(val: bool):
	print("can collect: "+String(can_collect))
	can_collect = val
	print("can collect: "+String(can_collect))

func _on_CollectableItem_input_event(viewport, event, shape_idx):
	if pick_up_range == 20:
		if event is InputEventMouseButton && not event.is_pressed() && not event.is_echo():
			#print(collectable_id)
			var player_pos = player.get_global_position()
			var my_pos = $Sprite.get_global_position()
			#print(player_pos.distance_to(my_pos))
			if player_pos.distance_to(my_pos) < pick_up_range:
				if(can_collect):
					var debug_print = str(item_name, ": sending signal" )
					print(debug_print)
					emit_signal("collectable_item_IE", event, item_name, collectable_id, item_qty)
					self.z_index = 10
