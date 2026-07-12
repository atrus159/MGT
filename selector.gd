extends Node3D


enum coords {
	X,
	Y,
	Z
}

enum modes {
	FREE,
	SELECTING,
	PLACING,
	LINEAR
}

enum style {
	empty = 0,
	surface = 1,
	selected = 2,
	starting = 3
}

var mode = modes.FREE;

var selectedPos = [0,0,0]
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
var selectedChar = null

var moveRange = 2
var rangeCells: Array
var rangeMesh: MeshInstance3D
var lines = []
var selectedLine = null
var linearDeselectTimer = 0

@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selection = $Selection

func _ready():
	field._clear_data_states()
	var selectionMesh = selection.get_node("SelectionMesh")
	selectionMesh.mesh = boxArrayMesh.make(field.spacing,field.spacing,field.spacing)
	selectionMesh.position = Vector3(0,0,0)
	selection.hide()

func _process(delta):
	match mode:
		modes.FREE:
			if Input.is_action_just_pressed("Select"):
				var clickedChar = Globals._mouse_get_clicked_character()
				if clickedChar != null:
					selectedChar = clickedChar
					mode = modes.SELECTING
					Globals.zoom_lockout = true
					selection.show()
					selectedPos = field._to_grid_space(clickedChar.position)
					selectedPlane.distance = selectedPos[2]
					selection.position = field._to_world_space(selectedPos)
					var AOE = field._make_range_mesh(selectedPos,moveRange)
					rangeCells = AOE.array
					rangeMesh = AOE.instance
			if Input.is_key_pressed(KEY_SPACE):
				mode = modes.PLACING
				selection.show()
		modes.SELECTING:
			
			if Input.is_key_pressed(KEY_SPACE):
				lines.clear()
				for i in range(-1,2):
					for j in range(-1,2):
						for k in range(-1,2):
							var newLine = field._make_line(selectedPos, [i,j,k] as Array[int])
							if newLine.instance != null:
								lines.append(newLine.instance)
				mode = modes.LINEAR
				Globals.zoom_lockout = false
				selection.hide()
				field._clear_data_states()
				selectorSuspend = 0
				selectedChar = null
				rangeMesh.queue_free()
				return
					
			
			if Input.is_action_just_pressed("Camera_Zoom_In"):
				if selectedPlane.distance > 0:
					selectedPlane.distance -= 1
					selectedPos[2] = selectedPlane.distance
					selection.position = field._to_world_space(selectedPos)
					if selectorSuspend != 2:
						selectorSuspend = 1
						prevSelected = field._get_mouse_plane_coords(selectedPlane)
					
			if Input.is_action_just_pressed("Camera_Zoom_Out"):
				if selectedPlane.distance < field.height - 1:
					selectedPlane.distance += 1
					selectedPos[2] = selectedPlane.distance
					selection.position = field._to_world_space(selectedPos)
					if selectorSuspend != 2:
						selectorSuspend = 1
						prevSelected = field._get_mouse_plane_coords(selectedPlane)
			if Input.is_action_just_pressed("Camera_Rotate"):
				selectorSuspend = 2
			if Input.is_action_just_released("Camera_Rotate"):
				selectorSuspend = 1
				prevSelected = field._get_mouse_plane_coords(selectedPlane)
				
			field._clear_data_states()
			field._set_data_states_plane(selectedPlane,style.surface, rangeCells)
			var test_selected = field._get_mouse_plane_coords(selectedPlane)
			
			if test_selected[0] != -1:
				if selectorSuspend == 1:
					if test_selected != prevSelected:
						selectorSuspend = 0
				if selectorSuspend == 0:
					selectedPos = test_selected
					selection.position = field._to_world_space(selectedPos)
					
			var fullBox: Array[int] = [1,1,1,1,1,1]
			field._set_data_state(field._to_grid_space(selectedChar.position),
					style.selected,
					fullBox
				)
			var inRange = rangeCells.has(selectedPos)
			if inRange:
				selection.get_node("SelectionMesh").set_instance_shader_parameter("wire_color", Color.GREEN)
				if Input.is_action_just_pressed("Select"):
					mode = modes.FREE
					Globals.zoom_lockout = false
					selection.hide()
					field._clear_data_states()
					selectorSuspend = 0
					field._move_character(selectedChar,selectedPos)
					selectedChar = null
					rangeMesh.queue_free()
			else:
				var red = Color.RED
				red.a = 0.5
				selection.get_node("SelectionMesh").set_instance_shader_parameter("wire_color", red)
		modes.PLACING:
			field._clear_data_states()
			field._set_data_states_plane(startingPlane,style.starting)
			var test_selected = field._get_mouse_plane_coords(startingPlane)
			if test_selected[0] != -1:
				selectedPos = test_selected
				selection.position = field._to_world_space(selectedPos)
			if Input.is_action_just_pressed("Select"):
				field._place_character(selectedPos)
				mode = modes.FREE
				selection.hide()
				field._clear_data_states()
		modes.LINEAR:
			if selectedLine == null:
				selectedLine = Globals._mouse_get_clicked_line()
				for line in lines:
					line._set_state(-1)
			else:
				for line in lines:
					line._set_state(-1)
				selectedLine._set_state(10)
				if !Globals._line_get_clicked(selectedLine):
					linearDeselectTimer += delta
					if linearDeselectTimer >= 0.1:
						selectedLine = null
						linearDeselectTimer = 0
				else:
					linearDeselectTimer = 0
	
