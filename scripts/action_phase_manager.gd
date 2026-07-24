extends Node3D


@onready var field = get_tree().current_scene.get_node("PlayingField")
@onready var selector = get_tree().current_scene.get_node("Selector")
@onready var UI = get_tree().current_scene.get_node("UI")
@onready var animationManager = get_tree().current_scene.get_node("AnimationManager")
@onready var planningPhaseManager = get_tree().current_scene.get_node("PlanningPhaseManager")



var turnOrder : Array[Node]
var animationLock = false
var active = false
var charIndex = 0
var abilityIndex = 0

enum states {
	START,
	TURN_PRE_ANIM,
	TURN_ABILITY,
	TURN_ANIM,
	TURN_END,
	END
}

var curState;

func _start():
	selector.selectedChar = null
	selector.field._clear_data_states()
	UI._start_action_phase()
	curState = states.START
	animationLock = true
	animationManager._set_timer(1)
	active = true
	charIndex = 0
	for curChar in get_tree().get_nodes_in_group("Characters"):
		var any = false
		for i in range(turnOrder.size()):
			var curPlacedChar = turnOrder[i]
			if curChar.speed < curPlacedChar.speed:
				turnOrder.insert(i, curChar)
				any = true
				break
		if !any:
			turnOrder.append(curChar)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		match curState:
			states.START:
				if !animationLock:
					curState = states.TURN_PRE_ANIM
					animationLock = true
					abilityIndex = 0
					animationManager._set_timer(1)
			states.TURN_PRE_ANIM:
				if !animationLock:
					curState = states.TURN_ABILITY
			states.TURN_ABILITY:
				var stillGoing = turnOrder[charIndex]._perform_ability(abilityIndex)
				if stillGoing:
					animationLock = true
					curState = states.TURN_ANIM
					animationManager._set_timer(1)
				else:
					curState = states.TURN_END
			states.TURN_ANIM:
				if !animationLock:
					curState = states.TURN_ABILITY
					abilityIndex +=1
			states.TURN_END:
				charIndex +=1
				if charIndex >= turnOrder.size():
					curState = states.END
				else:
					curState = states.TURN_PRE_ANIM
					animationLock = true
					abilityIndex = 0
					animationManager._set_timer(1)
			states.END:
				active = false
				planningPhaseManager._start()
