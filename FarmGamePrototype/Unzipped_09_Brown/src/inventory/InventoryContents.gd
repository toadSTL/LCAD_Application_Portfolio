extends Node

const ItemClass = preload("res://src/Inventory/Item.gd")
const SlotClass = preload("res://src/Inventory/slot.gd")
const NUM_INVENTORY_SLOTS = 30

var inventory  = {
	0: ["Watering Can", 1],
	1: ["Watering Can", 1],
	2: ["Tomato", 99],
	3: ["Pink Flower", 35],
	4: ["Pink Flower", 53],
	5: ["Rock", 50],
	6: ["Pink Flower", 81],
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func add_item(item_name, item_quantity):
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size =  int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				return
			else:
				inventory[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			return

func add_to_empty_slot(item: ItemClass, slot: SlotClass):
	inventory[slot.slot_index] = [item.item_name, item.item_quantity]

func remove_item(slot: SlotClass):
	inventory.erase(slot.slot_index)

func increase_item_quantity(slot: SlotClass, qty: int):
	inventory[slot.slot_index][1] += qty
	
func reduce_item_quantity(slot: SlotClass, qty: int):
	inventory[slot.slot_index][1] -= qty
