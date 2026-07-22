class_name character extends Node3D

var moveRange = 2
var actionQueue : Array[Dictionary]
var maxActionPoints = 6
var actionPoints = maxActionPoints
var abilityList : Array[ability]
var curAbility: int
var speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Characters")
	abilityList.resize(6)
	abilityList[0] = move_ability.new()
	abilityList[0]._attach(self)
	add_child(abilityList[0])


func _start_ability(n: int) -> bool:
	var selector = get_tree().current_scene.get_node("Selector")
	var ability = abilityList[n]
	if actionPoints >= ability.actionCost:
		selector._transition_mode(ability.mode)
		curAbility = n
		return true
	return false
	
func _end_ability(event: Dictionary):
	var ability = abilityList[curAbility]
	var queueData = ability._make_queue_data(event)
	actionQueue.append(queueData)
	actionPoints -= ability.actionCost
	
func _perform_queue():
	for i in range(actionQueue.size()):
		actionQueue[i].ability._perform_queue_data(actionQueue[i])
	actionQueue.clear()
	
func _perform_ability(i: int) -> bool:
	if i < actionQueue.size():
		actionQueue[i].ability._perform_queue_data(actionQueue[i])
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
