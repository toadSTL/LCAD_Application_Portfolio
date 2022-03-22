extends Node2D

const SlotClass = preload("res://src/Inventory/slot.gd")
const Item = preload("res://src/Inventory/item.tscn")
onready var inventory_slots = $GridContainer
var holding_item = null
var offset_vec = 5*Vector2.UP

func _ready():
	var slots  = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i
	initialize_inventory()
		
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holding_item !=null:
				if !slot.item:
					held_click_empty_slot(slot)
				else:
					held_click_occupied_slot(event, slot)
			elif slot.item:
				if Input.is_action_pressed("ctrl"):
					split_click_slot(slot)
				else:
					click_slot(slot)


func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if InventoryContents.inventory.has(i):
			slots[i].initialize_item(InventoryContents.inventory[i][0], InventoryContents.inventory[i][1])

func split_click_slot(slot: SlotClass):
	var slot_qty = slot.item.item_quantity
	if slot_qty == 1:
		return
	var held_qty = 0
	if not slot_qty%2 == 0:
		held_qty = slot_qty/2
		slot_qty = held_qty+1
	else:
		slot_qty = slot_qty/2
		held_qty = slot_qty
	var amt_to_red = slot.item.item_quantity-slot_qty
	InventoryContents.reduce_item_quantity(slot,amt_to_red)
	initialize_inventory()
	new_held_item(slot.item.item_name,held_qty)

func click_slot(slot: SlotClass):
	InventoryContents.remove_item(slot)
	holding_item = slot.item
	slot.pickFromSlot()
	holding_item.global_position = get_global_mouse_position() + offset_vec

func held_click_empty_slot(slot: SlotClass):
	#print(holding_item.item_name)
	InventoryContents.add_to_empty_slot(holding_item, slot)
	slot.putIntoSlot(holding_item)
	holding_item = null

func held_click_occupied_slot(event: InputEvent, slot: SlotClass):
	if holding_item.item_name != slot.item.item_name:
		InventoryContents.remove_item(slot)
		InventoryContents.add_to_empty_slot(holding_item, slot)
		var temp_item = slot.item
		slot.pickFromSlot()
		temp_item.global_position = get_global_mouse_position() + offset_vec
		slot.putIntoSlot(holding_item)
		holding_item = temp_item
	else:
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_quantity
		if able_to_add >= holding_item.item_quantity:
			InventoryContents.increase_item_quantity(slot, holding_item.item_quantity)
			slot.item.add_item_quantity(holding_item.item_quantity)
			destroy_holding_item() #
			#holding_item.queue_free()
			#holding_item = null
		else:
			InventoryContents.increase_item_quantity(slot, able_to_add)
			slot.item.add_item_quantity(able_to_add)
			holding_item.subtract_item_quantity(able_to_add)


func _process(delta):
	if holding_item:
		holding_item.global_position = get_global_mouse_position() + offset_vec
		#print(holding_item.position)
		#print(holding_item.visible)
		
func is_open():
	return visible

func destroy_holding_item():
	holding_item.queue_free()
	holding_item = null

func new_held_item(nm: String, qty: int):
	if not holding_item == null:
		InventoryContents.add_item(holding_item.item_name, holding_item.item_quantity)
		initialize_inventory()
		holding_item.queue_free()
	var new_item = Item.instance()
	add_child(new_item)
	new_item.global_position = get_global_mouse_position() + offset_vec
	new_item.set_item(nm,qty)
	holding_item = new_item
