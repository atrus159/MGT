extends Control

@onready var char_tab = $Character_Select
@onready var action_label = $ActionLabel
@onready var planning_label = $PlanningLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	char_tab.hide()
	action_label.hide()
	planning_label.hide()


func _show_character_tab(character: Node):
	char_tab.show()
	char_tab.get_node("Label").text = character.charName
	char_tab.get_node("ActionsLabel").text = "Actions: " + str(character.actionPoints)

func _hide_character_tab():
	char_tab.hide()
	
func _start_planning_phase():
	planning_label.show()
	action_label.hide()
	
func _start_action_phase():
	action_label.show()
	planning_label.hide()
	char_tab.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
