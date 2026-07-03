extends Node3D


enum coords {
	X,
	Y,
	Z
}

var selected = [0,0,0]
var selectedPlane = {
	"direction": coords.Z,
	"distance": 5
}
@onready var field = get_tree().current_scene.get_node("Playing_Field")
@onready var selection = get_tree().current_scene.get_node("Selection")

@onready var firstFlag = 0

func _process(delta):
	if firstFlag == 0:
		field._clear_data_states()
		field._set_data_states_plane(selectedPlane.distance)
		firstFlag = 1
	selected = field._get_mouse_plane_coords(selectedPlane)
	if selected[0] != -1:
		selection.position = field._to_world_space(selected)
	
