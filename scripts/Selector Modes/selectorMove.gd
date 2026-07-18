class_name selectorMove extends selectorMode


var selectedPlane = {
	"direction": Globals.coords.Z,
	"distance": 5
}

var selectedPos : Array[int] = [-1,-1,-1]

func _calc(selector: Node) -> Dictionary:					
	var newPos = [selectedPos[0], selectedPos[1]]
	var planeChanged = false
	if Input.is_action_just_pressed("Camera_Zoom_In"):
		if selectedPlane.distance > 0:
			selectedPlane.distance -= 1
			selectedPos[2] = selectedPlane.distance
			planeChanged = true
	
	if Input.is_action_just_pressed("Camera_Zoom_Out"):
		if selectedPlane.distance < selector.field.height - 1:
			selectedPlane.distance += 1
			selectedPos[2] = selectedPlane.distance
			planeChanged = true
	
	if !planeChanged:
		var test_selected = selector.field._get_mouse_plane_coords(selectedPlane)
		if test_selected[0] != -1:
			newPos = test_selected
	
	return {
		"pos": newPos,
	}

func _update(selector: Node, result: Dictionary) -> Dictionary:
	selectedPos = [result.pos[0],result.pos[1],selectedPos[2]] as Array[int]
	selector.selection.position = selector.field._to_world_space(selectedPos)
	selector.field._clear_data_states()
	selector.field._set_data_states_plane(selectedPlane,Globals.style.SURFACE, selector.rangeCells)
	var fullBox: Array[int] = [1,1,1,1,1,1]
	selector.field._set_data_state(selector.field._to_grid_space(selector.selectedChar.position),
			Globals.style.SELECTED,
			fullBox
		)
	var inRange = selector.rangeCells.has(selectedPos)
	if inRange:
		selector.selection.get_node("SelectionMesh").set_instance_shader_parameter("wire_color", Color.GREEN)
		if Input.is_action_just_pressed("Select"):
			return {
				"pos": selectedPos
			}
	else:
		var red = Color.RED
		red.a = 0.5
		selector.selection.get_node("SelectionMesh").set_instance_shader_parameter("wire_color", red)
	
	return {}



func _start(selector: Node) -> Dictionary:
	Globals.zoom_lockout = true
	selector.selection.show()
	selectedPos = selector.field._to_grid_space(selector.selectedChar.position)
	selectedPlane.distance = selectedPos[2]
	selector.selection.position = selector.field._to_world_space(selectedPos)
	var AOE = selector.field._make_range_mesh(selectedPos,selector.selectedChar.moveRange)
	selector.rangeCells = AOE.array
	selector.rangeMesh = AOE.instance
	return {}
		
func _end(selector: Node) -> Dictionary:
	Globals.zoom_lockout = false
	selector.selection.hide()
	selector.field._clear_data_states()
	selector.rangeMesh.queue_free()
	return {}
