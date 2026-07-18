class_name selectorFree extends selectorMode


func _calc(selector: Node) -> Dictionary:					
	return {}

func _update(selector: Node, result: Dictionary) -> Dictionary:
	if Input.is_action_just_pressed("Select"):
		var clickedCharDictionary = Globals._mouse_get_clicked_character()
		if !clickedCharDictionary.is_empty():
			return clickedCharDictionary
	return {}


func _start(selector: Node) -> Dictionary:
	selector.selectedChar = null
	return {}
		
func _end(selector: Node) -> Dictionary:
	return {}
