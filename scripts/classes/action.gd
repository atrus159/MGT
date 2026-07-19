class_name action extends Node

var mode : selectorMode;
var character: Node;
var actionCost = 1

@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selector = get_tree().current_scene.get_node("Selector")


func _attach(char: Node):
	character = char


func _make_queue_data(selectorData: Dictionary) -> Dictionary:
	return {}
	
func _perform_queue_data(queueData: Dictionary):
	return
