extends Label


var stats = []

func _ready():
	pass # Replace with function body.

func add_stat(stat_name, object, stat_ref,  is_method):
	stats.append([stat_name,object,stat_ref,is_method])
	
func _process(delta):
	var label_text = ""
	
	var fps = Engine.get_frames_per_second()
	label_text += str("FPS: ", fps)
	label_text += "\n"
	
	var mem = OS.get_static_memory_usage()
	label_text += str("Static Mem.: ", String.humanize_size(mem))
	label_text += "\n"
	for s in stats:
		var value = null
		if s[1] and weakref(s[1]).get_ref():
			if s[0] == "Player Position":
				var temp = s[1].get(s[2])
				#print(temp)
				#print(temp.floor())
				value = temp.floor()
			else:
				if s[3]:
					value = s[1].call(s[2])
				else:
					value = s[1].get(s[2])
		label_text += str(s[0], ": ", value)
		label_text += "\n"
	text = label_text
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass