extends Node


var item_data: Dictionary
var demo_lvl_item_set: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = LoadData("res://data/itemData.json")
	#demo_lvl_item_set = LoadData("res://data/lvl_demo_item_set.json")
	#print(item_data)

func LoadData(filePath):
	var json_data
	var file_data = File.new()
	
	file_data.open(filePath,File.READ)
	json_data = JSON.parse(file_data.get_as_text())
	file_data.close()
	print(json_data.result)
	return json_data.result
