extends MeshInstance3D

@onready var field = get_tree().current_scene.get_node("PlayingField")
@export var length = 3
@export var width = 2
@export var height = 3
@export var x = 2
@export var y = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	field._establish_building(x,y,0,length,width,height,self)
	position = field._to_world_space([x,y,0] as Array[int])
	mesh = boxArrayMesh.make(Globals.spacing*length,Globals.spacing*width,Globals.spacing*height-0.01)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
