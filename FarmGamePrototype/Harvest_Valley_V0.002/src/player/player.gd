extends KinematicBody2D
# Comments
onready var sprite = $Sprite
onready var col_shape = $CollisionShape2D
onready var anim_tree = $AnimationTree 
onready var state_mac = $AnimationTree.get("parameters/playback")
onready var shadow = $Shadow


var count = 0

var num_items = 0

var idle setget set_idle, is_idle
var walking setget set_walking, is_walking
var running setget set_running, is_running
var jumping setget set_jumping, get_jumping
var taking setget set_taking, get_taking
var on_platform setget set_on_platform, is_on_platform
# Need player characteristic data

onready var map = get_parent()
onready var collectable_item_nodes = map.collectable_items
onready var inventory = get_node("../../UserInterface/Inventory")
var hand_display_vec = Vector2(-8,-16)
var canv_pos
var item_in_hand
var item_in_hand_name
var item_in_hand_qty

var hand_to_inventory = false

var vel = 0

export (bool) var is_jumping
export (bool) var is_idle
export (bool) var is_walking
export (bool) var is_running
 
var pick_up_range = 30.0
var sawd = [0,0,0,0]
enum {UNPRESSED, PRESSED, LAST_PRESSED, DOWN, LEFT, UP, RIGHT}
var d = DOWN
var last_input

export (float) var jump_height
export (int) var shadow_offset
export (float) var z_gravity_rate
var shadow_offset_vec = Vector2.ZERO
var z_offset_vec = Vector2.ZERO
var init_jump_vel
var cur_jump_vel = 0
var jump_time = 0.2
var one_half = 0.5
var z = 0
var z_floor = 0
var z_gravity = 0

var d_var = UNPRESSED
var w_var = UNPRESSED
var a_var = UNPRESSED
var s_var = UNPRESSED
export var speed :=  180.00
var eff_speed
var input_vector = Vector2.ZERO
var move_direction = Vector2.ZERO
var face_direction = Vector2.DOWN
var total_move

var s_time = 0
var c_time = 0
signal held_item_to_map(item_nm, item_pos, item_qty, item_type)

func _ready():
	map.connect("new_collectable_item", self, "connect_collectable_item")
	init_jump_vel = 200
	set_idle(1)
	set_walking(0)
	set_running(0)
	set_jumping(0)
	set_taking(0)
	is_idle = true
	is_walking = false
	is_jumping = false
	is_running = false

func connect_collectable_item(id: int):
	collectable_item_nodes = get_parent().items_for_collection()
	collectable_item_nodes[id].connect("collectable_item_IE", self, "collect_item_IE")
	collectable_item_nodes[id].connect("quick_collect", self, "quick_collect_item")
	
func _input(event):
	if event.is_action_pressed("jump"):
		_last_pressed_to_pressed()
		jump()
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && !event.pressed:
			var temp_pos = get_global_mouse_position()
			#print(temp_pos)
			print(global_position)
			if inventory.is_open() && inventory.holding_item != null && global_position.distance_to(temp_pos) < 30:
				var temp = inventory.holding_item
				var temp_type = 1
				if temp.item_type == "Tool":
					temp_type = 0
				emit_signal("held_item_to_map", temp.item_name, temp_pos, temp.item_quantity, temp_type)
				inventory.destroy_holding_item()
	# Handle direction player faces
	last_input = event.as_text()
	if last_input.begins_with("Shift+"):
		last_input.erase(0,6)
	if event.is_pressed():
		match last_input :
			'D' :
				if d_var == UNPRESSED:
					_last_pressed_to_pressed()
					sawd[3] = LAST_PRESSED
					d_var = PRESSED
			'W' :
				if w_var == UNPRESSED:
					_last_pressed_to_pressed()
					sawd[2] = LAST_PRESSED
					w_var = PRESSED
			'A' :
				if a_var == UNPRESSED:
					_last_pressed_to_pressed()
					sawd[1] = LAST_PRESSED
					a_var = PRESSED
			'S' :
				if s_var == UNPRESSED:
					_last_pressed_to_pressed()
					sawd[0] = LAST_PRESSED
					s_var = PRESSED
	else:
		match last_input :
			'D' :
				_last_pressed_to_pressed()
				sawd[3] = UNPRESSED
				d_var = UNPRESSED
			'W' :
				_last_pressed_to_pressed()
				sawd[2] = UNPRESSED
				w_var = UNPRESSED
			'A' :
				_last_pressed_to_pressed()
				sawd[1] = UNPRESSED
				a_var = UNPRESSED
			'S' :
				_last_pressed_to_pressed()
				sawd[0] = UNPRESSED
				s_var = UNPRESSED

func _process(delta):
	if hand_to_inventory:
		if inventory.is_open(): 
			inventory.new_held_item(item_in_hand_name, item_in_hand_qty)
		else:
			InventoryContents.add_item(item_in_hand_name,item_in_hand_qty)
			inventory.initialize_inventory() 
		item_in_hand.queue_free()
		item_in_hand = null
		hand_to_inventory = false
	num_items = collectable_item_nodes.size()
			
func _physics_process(delta):
	
	input_vector = Vector2(
		Input.get_action_strength("east") -  Input.get_action_strength("west"),
		Input.get_action_strength("south") - Input.get_action_strength("north")
	)
	
	move_direction = input_vector.normalized()
	eff_speed = speed
	set_d()
	match d :
		RIGHT :
			face_direction = Vector2.RIGHT
		UP :
			face_direction = Vector2.UP
		LEFT :
			face_direction = Vector2.LEFT
		DOWN :
			face_direction = Vector2.DOWN
	face_direction = (2*move_direction+face_direction).normalized()
	
	if(move_direction != Vector2.ZERO):
		anim_tree.set("parameters/idle/blend_position", face_direction)
		anim_tree.set("parameters/walk/blend_position", face_direction)
		anim_tree.set("parameters/run/blend_position", face_direction)
		anim_tree.set("parameters/jump/blend_position", face_direction)
		anim_tree.set("parameters/take/blend_position", face_direction)
	if(move_direction == Vector2.ZERO):
		set_taking(0)
		set_walking(0)
		set_running(0)
		set_idle(1)
	elif Input.is_action_pressed("run"):
		set_taking(0)
		set_idle(0)
		set_walking(0)
		set_running(1)
		eff_speed = speed*1.65
	else:
		set_idle(0)
		set_running(0)
		set_walking(1)

	shadow_offset_vec = shadow_offset*Vector2.DOWN
	shadow.set("offset", shadow_offset_vec)
	z_offset_vec = z*Vector2.UP
	sprite.set("offset", z_offset_vec)
	vel = eff_speed*move_direction
	move_and_slide(vel)
	z_motion(delta)
	canv_pos = get_global_transform_with_canvas()

#Like the associated variable declarations above, I am unsure if these function declarations do anything
func set_idle(value):
	anim_tree.set("parameters/conditions/idle", value)
func is_idle():
	anim_tree.get("parameters/conditions/idle")
func set_walking(value):
	anim_tree.set("parameters/conditions/walking", value)
func is_walking():
	anim_tree.get("parameters/conditions/walking")
func set_running(value):
	anim_tree.set("parameters/conditions/running", value)
func is_running():
	anim_tree.get("parameters/conditiosn/running")
func set_jumping(value):
	anim_tree.set("parameters/conditions/jumping", value)
func get_jumping():
	anim_tree.get("parameters/conditiosn/jumping")
func set_taking(value):
	anim_tree.set("parameters/conditions/taking", value)
func get_taking():
	anim_tree.get("parameters/conditiosn/taking")
func set_on_platform(value):
	on_platform = value
func is_on_platform():
	return on_platform
	

	

func set_d():
	if sawd.has(LAST_PRESSED):
		d = sawd.find(LAST_PRESSED) + 3
	elif sawd.has(PRESSED):
		d = sawd.find(PRESSED) + 3
	#count += 1
	#print(String(count)+":"+String(d))

func _last_pressed_to_pressed():
	for i in range(0, sawd.size()):
		if sawd[i] == LAST_PRESSED:
			sawd[i] = PRESSED

func jump():
	var test = is_jumping
	if !is_jumping:
		speed = 0
	set_jumping(1)
	is_jumping = true
	state_mac.travel("jump")

func z_move():
	print("jump_test")
	speed = 180.0
	cur_jump_vel = init_jump_vel

func z_motion(delta):
	z += cur_jump_vel*delta
	if(z >= 40):
		set_collision_layer_bit(0,0)
		set_collision_mask_bit(0,0)
		set_collision_layer_bit(1,0)
		set_collision_mask_bit(1,0)
		set_collision_layer_bit(2,1)
		set_collision_mask_bit(2,1)
	elif(z >= 20):
		set_collision_layer_bit(0,0)
		set_collision_mask_bit(0,0)
		set_collision_layer_bit(1,1)
		set_collision_mask_bit(1,1)
		set_collision_layer_bit(2,1)
		set_collision_mask_bit(2,1)
	else:
		set_collision_layer_bit(0,1)
		set_collision_mask_bit(0,1)
		set_collision_layer_bit(1,1)
		set_collision_mask_bit(1,1)
		set_collision_layer_bit(2,1)
		set_collision_mask_bit(2,1)
	if (z <= z_floor && cur_jump_vel < 0):
		cur_jump_vel = 0
		if(z_floor == 20):
			set_collision_layer_bit(0,0)
			set_collision_mask_bit(0,0)
		set_jumping(0)
		is_jumping = false
		z = z_floor
	elif cur_jump_vel == 0:
		return
	else:
		cur_jump_vel -= z_gravity_rate*delta

func _on_area_entered(area):
	if not area is Platform:
		return
	print("entered platform")
	z_floor += area.height
	shadow_offset -=area.height
	set_on_platform(1)
	


func _on_area_exited(area):
	if area is Platform:
		z_floor -= area.height
		if not is_jumping:
			cur_jump_vel = -10
		shadow_offset +=area.height
		set_on_platform(0) #

func quick_collect_item(nm, id, qt):
	print("got here")
	if inventory.is_open(): 
		inventory.new_held_item(nm, qt)
		#map.item_collected_refactor(id)
		collectable_item_nodes[id].queue_free()
		#collectable_item_nodes.erase(collectable_item_nodes[id])
		#var temp = collectable_item_nodes[id]
		#collectable_item_nodes.erase(temp)
		
	else:
		InventoryContents.add_item(nm,qt)
		inventory.initialize_inventory()
		#map.item_collected_refactor(id)
		collectable_item_nodes[id].queue_free()
		#var temp = collectable_item_nodes[id]
		
		#the array update is skrewed up by the fact that the items are broadcasting their to the player
		#either we need to update the way we get ids or we need to update the ids of each item whenever
		#we collect an item.
		
#func _on_CollectableItem_input_event(viewport, event, shape_idx, col_item_name, col_item_id):
func collect_item_IE(ev, col_item_name, col_item_id, col_item_qty):
	#if not ev.is_echo():
	#event is InputEventMouseButton && not event.is_pressed() && 
	#print(get_global_position().distance_to(col_item_pos))
	#if get_global_position().distance_to(col_item_pos) < pick_up_range:
	#print("got here")
	set_taking(1)
	speed = 0.0
	print("run take animation")
	state_mac.travel("take")
	#map.item_collected_refactor(col_item_id)
	item_in_hand_name = col_item_name
	item_in_hand_qty = col_item_qty
	item_in_hand = collectable_item_nodes[col_item_id]
	item_in_hand.position = position+hand_display_vec

func hand_to_inventory():
	hand_to_inventory = true
	speed = 180.0
	

func get_canvas_pos():
	return canv_pos



