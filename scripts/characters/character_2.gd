class_name character_2 extends character


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	speed = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
