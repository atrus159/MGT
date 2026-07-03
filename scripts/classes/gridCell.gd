class_name gridCell

var contents: Node

func _init():
	contents = null

func set_contents(toSet: Node):
	contents = toSet
	
func get_contents() -> Node:
	return contents
