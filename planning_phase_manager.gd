extends Node3D

@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selector = get_tree().current_scene.get_node("Selector")

var characterOne = preload("res://assets/scenes/character.tscn")
var characterTwo = preload("res://assets/scenes/character.tscn")
var characterThree = preload("res://assets/scenes/character.tscn")
var charactersPlacedCount = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selector._attach(self)
	selector._transition_mode(selector.mode_place)


func _selector_event(event: Dictionary):
	if charactersPlacedCount == 0:
		field._place_character(event.pos, characterOne)
		charactersPlacedCount = 1
	elif charactersPlacedCount == 1:
		field._place_character(event.pos, characterTwo)
		charactersPlacedCount = 2
	elif charactersPlacedCount == 2:
		field._place_character(event.pos, characterThree)
		selector._transition_mode(selector.mode_free)
		charactersPlacedCount = 3
	else:
		selector.field._clear_data_states()
		if event.position == Vector3(-999,-999,-999):
			selector.selectedChar = null
		else:
			selector.selectedChar = event.collider
			var fullBox: Array[int] = [1,1,1,1,1,1]
			selector.field._set_data_state(selector.field._to_grid_space(selector.selectedChar.position),
					Globals.style.SELECTED,
					fullBox
				)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
