class_name gridCell

var contents: Node
var building_inside: Node
var index: int

func _init():
	contents = null
	building_inside = null
	index = 0

func set_contents(toSet: Node):
	contents = toSet
	
func get_contents() -> Node:
	return contents
