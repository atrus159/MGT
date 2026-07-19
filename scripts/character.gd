extends Node3D

var moveRange = 2
var actionQueue : Array[Dictionary]
var maxActionPoints = 6
var actionPoints = maxActionPoints
var actionList : Array[action]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Characters")
	actionQueue.resize(6)
	actionList.resize(6)
	actionList[0] = move_action.new()
	add_child(actionList[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
