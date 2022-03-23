extends Area2D
class_name Platform

export (int) var z # bottom
export (int) var height # how tall

func _ready():
	height = z + height
