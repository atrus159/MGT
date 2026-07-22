extends Node3D

@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selector = get_tree().current_scene.get_node("Selector")
@onready var UI = get_tree().current_scene.get_node("CharacterUI")
@onready var actionPhaseManager = get_tree().current_scene.get_node("ActionPhaseManager")

var characterOne = preload("res://scripts/characters/character_1.tscn")
var characterTwo = preload("res://scripts/characters/character_2.tscn")
var characterThree = preload("res://scripts/characters/character_3.tscn")

enum states {
	PLACING_ONE,
	PLACING_TWO,
	PLACING_THREE,
	FREE,
	SELECTED,
	ABILITY
}

var curState : states;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selector._attach(self)
	selector._transition_mode(selector.mode_place)
	curState = states.PLACING_ONE

func _selector_event(event: Dictionary):
	match curState:
		states.PLACING_ONE:
			field._place_character(event.pos, characterOne)
			curState = states.PLACING_TWO
		states.PLACING_TWO:
			field._place_character(event.pos, characterTwo)
			curState = states.PLACING_THREE
		states.PLACING_THREE:
			field._place_character(event.pos, characterThree)
			selector._transition_mode(selector.mode_free)
			curState = states.FREE
		states.FREE:
			if event.position != Vector3(-999,-999,-999):
				selector.selectedChar = event.collider
				selector.field._clear_data_states()
				var fullBox: Array[int] = [1,1,1,1,1,1]
				selector.field._set_data_state(selector.field._to_grid_space(selector.selectedChar.position),
						Globals.style.SELECTED,
						fullBox
					)
				curState = states.SELECTED
				UI.show()
		states.SELECTED:
			if event.position == Vector3(-999,-999,-999):
				selector.field._clear_data_states()
				selector.selectedChar = null
				curState = states.FREE
				UI.hide()
			elif event.position != Vector3(-999,-999,-999):
				selector.selectedChar = event.collider
				selector.field._clear_data_states()
				var fullBox: Array[int] = [1,1,1,1,1,1]
				selector.field._set_data_state(selector.field._to_grid_space(selector.selectedChar.position),
						Globals.style.SELECTED,
						fullBox
					)
				curState = states.SELECTED
		states.ABILITY:
			selector.selectedChar._end_ability(event)
			selector._transition_mode(selector.mode_free)
			curState = states.FREE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match curState:
		states.SELECTED:
			if Input.is_action_just_pressed("ability_1"):
				if selector.selectedChar._start_ability(0):
					curState = states.ABILITY
	if Input.is_action_just_pressed("ability_2"):
		actionPhaseManager._start()
		curState = states.FREE
