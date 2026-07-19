extends Node3D


var selectorSuspend = 0
var selectedChar = null

var rangeCells: Array
var rangeMesh: MeshInstance3D
var delta_t = 0

@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selection = $Selection

var mode_move = selectorMove.new()
var mode_place = selectorPlace.new()
var mode_free = selectorFree.new()
var mode_line = selectorLine.new()
var cur_mode : selectorMode = mode_free
var prevData = {}

func _ready():
	field._clear_data_states()
	var selectionMesh = selection.get_node("SelectionMesh")
	selectionMesh.mesh = boxArrayMesh.make(Globals.spacing,Globals.spacing,Globals.spacing)
	selectionMesh.position = Vector3(0,0,0)
	selection.hide()

func _transition_mode(new_mode : selectorMode):
	selectorSuspend = 0
	cur_mode._end(self)
	new_mode._start(self)
	cur_mode = new_mode

func _process(delta):
	delta_t = delta
	if Input.is_action_just_pressed("Camera_Zoom_In"):
		if selectorSuspend != 2:
			selectorSuspend = 1
	if Input.is_action_just_pressed("Camera_Zoom_Out"):
		if selectorSuspend != 2:
			selectorSuspend = 1
	if Input.is_action_just_pressed("Camera_Rotate"):
		selectorSuspend = 2
	if Input.is_action_just_released("Camera_Rotate"):
		selectorSuspend = 1
	
	var result = cur_mode._calc(self)
	var finalResult;
	if selectorSuspend == 1 and result != prevData:
		selectorSuspend = 0
	if selectorSuspend == 0:
		finalResult = cur_mode._update(self, result)
		prevData = result
	else:
		finalResult = cur_mode._update(self, prevData)
	
	if Input.is_key_pressed(KEY_SPACE):
		if cur_mode is selectorFree:
			_transition_mode(mode_place)
			return
		elif cur_mode is selectorMove:
			_transition_mode(mode_line)
			return
			
	if !finalResult.is_empty():
		if cur_mode is selectorFree:
			selectedChar = finalResult.collider
			_transition_mode(mode_move)
		elif cur_mode is selectorMove:
			field._move_character(selectedChar,finalResult.pos)
			_transition_mode(mode_free)
			pass
		elif cur_mode is selectorPlace:
			field._place_character(finalResult.pos)
			_transition_mode(mode_free)
			pass
		elif cur_mode is selectorLine:
			if finalResult.pos[0] != -1:
				field._move_character(selectedChar,finalResult.pos)
			_transition_mode(mode_free)
			pass
