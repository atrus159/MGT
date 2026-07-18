class_name gridCell

var contents: Node
var building_inside: Node

func _init():
	contents = null
	building_inside = null

func set_contents(toSet: Node):
	contents = toSet
	
func get_contents() -> Node:
	return contents
