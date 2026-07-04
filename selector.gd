extends Node3D


enum coords {
	X,
	Y,
	Z
}

enum modes {
	FREE,
	SELECTING,
	PLACING
}

var mode = modes.FREE;

var selected = [0,0,0]
var selectedPlane = {
	"direction": coords.Z,
	"distance": 5
}

var startingPlane = {
	"direction": coords.Y,
	"distance": 0
}

var selectorSuspend = 0
var prevSelected = [0,0,0]

@onready var field = get_tree().current_scene.get_node("Playing_Field")
@onready var selection = get_tree().current_scene.get_node("Selection")

func _ready():
	field._clear_data_states()
	var selectionMesh = selection.get_node("SelectionMesh")
	selectionMesh.mesh = boxArrayMesh.make(field.spacing,field.spacing,field.spacing)
	selectionMesh.position = Vector3(0,0,0)
	selection.hide()

func _process(delta):
	match mode:
		modes.FREE:
			if Input.is_key_pressed(KEY_SPACE):
				mode = modes.SELECTING
				Globals.zoom_lockout = true
				selection.show()
			if Input.is_key_pressed(KEY_0):
				mode = modes.PLACING
				selection.show()
		modes.SELECTING:
			if Input.is_action_just_pressed("Camera_Zoom_In"):
				if selectedPlane.distance > 0:
					selectedPlane.distance -= 1
					selected[2] = selectedPlane.distance
					selection.position = field._to_world_space(selected)
					if selectorSuspend != 2:
						selectorSuspend = 1
						prevSelected = field._get_mouse_plane_coords(selectedPlane)
					
			if Input.is_action_just_pressed("Camera_Zoom_Out"):
				if selectedPlane.distance < field.height - 1:
					selectedPlane.distance += 1
					selected[2] = selectedPlane.distance
					selection.position = field._to_world_space(selected)
					if selectorSuspend != 2:
						selectorSuspend = 1
						prevSelected = field._get_mouse_plane_coords(selectedPlane)
			if Input.is_action_just_pressed("Camera_Rotate"):
				selectorSuspend = 2
			if Input.is_action_just_released("Camera_Rotate"):
				selectorSuspend = 1
				prevSelected = field._get_mouse_plane_coords(selectedPlane)
				
			field._clear_data_states()
			field._set_data_states_plane(selectedPlane.distance)
			var test_selected = field._get_mouse_plane_coords(selectedPlane)
			
			if test_selected[0] != -1:
				if selectorSuspend == 1:
					if test_selected != prevSelected:
						selectorSuspend = 0
				if selectorSuspend == 0:
					selected = test_selected
					selection.position = field._to_world_space(selected)
			
			if Input.is_action_just_pressed("Select"):
				mode = modes.FREE
				Globals.zoom_lockout = false
				selection.hide()
				field._clear_data_states()
		modes.PLACING:
			field._clear_data_states()
			var test_selected = field._get_mouse_plane_coords(startingPlane)
			if test_selected[0] != -1:
				selected = test_selected
				selection.position = field._to_world_space(selected)
	
