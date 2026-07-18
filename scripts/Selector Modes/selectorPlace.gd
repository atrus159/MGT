class_name selectorPlace extends selectorMode


var startingPlane = {
	"direction": Globals.coords.Y,
	"distance": 0
}

var selectedPos : Array[int] = [-1,-1,-1]

func _calc(selector: Node) -> Dictionary:
	var newPos = selectedPos
	var test_selected = selector.field._get_mouse_plane_coords(startingPlane)
	if test_selected[0] != -1:
		newPos = test_selected
		
	return {
		"pos": newPos,
	}
	
func _update(selector: Node, result: Dictionary) -> Dictionary:
	selectedPos = result.pos as Array[int]
	selector.selection.position = selector.field._to_world_space(selectedPos)
	selector.field._clear_data_states()
	selector.field._set_data_states_plane(startingPlane,Globals.style.STARTING)
	if Input.is_action_just_pressed("Select"):
		return {
			"pos": selectedPos
		}
	return {}


func _start(selector: Node) -> Dictionary:
	selector.selection.show()
	selector.field._clear_data_states()
	selector.field._set_data_states_plane(startingPlane,Globals.style.STARTING)
	selector.selectedChar = null
	return {}
		
func _end(selector: Node) -> Dictionary:
	selector.selection.hide()
	selector.field._clear_data_states()
	return {}
