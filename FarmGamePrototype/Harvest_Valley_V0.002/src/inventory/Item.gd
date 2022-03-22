extends Node2D

var item_name
var item_quantity
var item_type

func _ready():
	pass
	#$TextureRect.texture = null
	#var rand_val = randi()%3
	#match rand_val:
	#	0:
	#		item_name = "Rock"
	#	1:
	#		item_name = "Pink Flower"
	#	2:
	#		item_name = "Watering Can"
	#$TextureRect.texture = load("res://assets/obj/obj_icon/"+JsonData.item_data[item_name]["FileName"])
	#var stack_size = int(JsonData.item_data[item_name]["StackSize"])		
	#item_quantity = randi()%stack_size+1
	#if stack_size == 1:
	#	$Label.visible=false
	#else:
	#	$Label.text = String(item_quantity)

func add_item_quantity(ammount_to_add):
	item_quantity += ammount_to_add
	$Label.text = String(item_quantity)
	
func subtract_item_quantity(ammount_to_sub):
	item_quantity -= ammount_to_sub
	$Label.text = String(item_quantity)
	
func set_item(new_name, new_quantity):
	item_name = new_name
	#print(new_quantity)
	item_quantity = new_quantity
	$TextureRect.texture = load("res://assets/obj/obj_icon/"+JsonData.item_data[item_name]["FileName"])
	#print($TextureRect.texture)
	item_type = JsonData.item_data[item_name]["ItemCategory"]
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = String(item_quantity)
