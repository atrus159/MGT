extends Node3D

var timer = 0
var running = false
@onready var actionPhaseManager = get_tree().current_scene.get_node("ActionPhaseManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		timer -= delta
		if timer <= 0:
			timer = 0
			running = false
			actionPhaseManager.animationLock = false
			


func _set_timer(n):
	timer = n
	running = true
