extends TileMap
signal new_collectable_item(item_id)
var CURRENT_ITEM_INDEX_OFFSET = 2
var CollectableItemClass = preload("res://src/env/Collectable_Item.tscn")
var collectable_items: Array
onready var player = get_child(0)
var num_items = 0
var timer

var SHORT_ITEM_PICK_UP_RANGE = 20.0
var LONG_ITEM_PICK_UP_RANGE = 50.0

var collectable_item_data  = {
	0: {
		"Name": "Watering Can",
		"Global_Position": {
			"x": 960,
			"y": 256
		},
		"Quantity": 1,
		"Type": 0
	},
	1: {
		"Name": "Tomato",
		"Global_Position": {
			"x": 270,
			"y": 456.30899
		},
		"Quantity": 2,
		"Type": 1
	},
	2: {
		"Name": "Tomato",
		"Global_Position": {
			"x": 306,
			"y": 468
		},
		"Quantity": 1,
		"Type": 1
	},
	3: {
		"Name": "Rock",
		"Global_Position": {
			"x": 1056,
			"y": 168
		},
		"Quantity": 1,
		"Type": 1
	},
	4: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 1024,
			"y": 128
		},
		"Quantity": 1,
		"Type": 1
	},
	5: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 836,
			"y": 88
		},
		"Quantity": 1,
		"Type": 1
	},
	6: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 832,
			"y": 96
		},
		"Quantity": 1,
		"Type": 1
	},
	7: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 840,
			"y": 80
		},
		"Quantity": 1,
		"Type": 1
	},
	8: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 836,
			"y": 104
		},
		"Quantity": 1,
		"Type": 1
	},
	9: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 856,
			"y": 68
		},
		"Quantity": 1,
		"Type": 1
	},
	10: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 864,
			"y": 60
		},
		"Quantity": 1,
		"Type": 1
	},
	11: {
		"Name": "Pink Flower",
		"Global_Position": {
			"x": 900,
			"y": 100
		},
		"Quantity": 1,
		"Type": 1
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	add_child(timer)
	for item_id in collectable_item_data:
		instantiate_item(item_id)
	player.connect("held_item_to_map", self, "new_item_data")
	num_items = collectable_items.size()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	num_items = player.num_items
	#print(num_items)
#	pass
func items_for_collection():
	return collectable_items

#not used?
func item_collected_refactor(id: int):
	collectable_items.remove(id)

func instantiate_item(item_id):
	var item = CollectableItemClass.instance()
	var item_info = collectable_item_data[item_id]
	var item_name = item_info["Name"]
	var item_quantity = item_info["Quantity"]
	var item_pos = Vector2(item_info["Global_Position"]["x"],item_info["Global_Position"]["y"])
	item.set_global_position(item_pos)
	item.z_index = 1
	item.z_as_relative = true
	var pur = 0.0
	if item_info["Type"] == 0:
		pur = SHORT_ITEM_PICK_UP_RANGE
		timer.wait_time = 0.1
	else:
		pur = LONG_ITEM_PICK_UP_RANGE
		timer.wait_time = 0.5
	item.initialize_item(item_name,item_id,item_quantity, pur)
	add_child(item)
	collectable_items.append(item)
	emit_signal("new_collectable_item", item_id)
	
	timer.start()
	yield(timer,"timeout")
	collectable_items[item_id].set_collectable(true)

func new_item_data(nm, pos: Vector2, qty, t):
	var cur_item_id = collectable_item_data.size()
	#print(cur_item_id)
	collectable_item_data[cur_item_id] = {
		"Name": nm,
		"Global_Position": {
			"x": pos.x,
			"y": pos.y
		},
		"Quantity": qty,
		"Type": t
	}
	instantiate_item(cur_item_id)
	#print(collectable_item_data.size())

func get_player():
	return player
