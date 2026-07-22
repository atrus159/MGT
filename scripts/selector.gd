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
var cur_mode : selectorMode = mode_free
var prevData = {}
var active = false
var manager : Node = null

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
	
func _attach(newManager: Node):
	manager = newManager
	active = true

func _detach():
	manager = null
	active = false

func _process(delta):
	if active:
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
				
		if !finalResult.is_empty():
			manager._selector_event(finalResult)
