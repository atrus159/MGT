extends StaticBody3D


@onready var multiMeshInstance = $MultiMeshInstance3D
@onready var collisionShape = $CollisionShape3D
var spacing = Globals.spacing
var pointList
const AOE_material = preload("res://assets/shaders/AOE_shader_multimesh_material.tres")
var multiMesh
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Lines")
	multiMesh = MultiMesh.new()
	multiMesh.transform_format = MultiMesh.TRANSFORM_3D
	multiMesh.use_custom_data = true
	multiMesh.mesh = boxArrayMesh.make(spacing,spacing,spacing)
	multiMesh.mesh.surface_set_material(0, AOE_material)
	multiMeshInstance.multimesh = multiMesh

func _initiate(points: Array):
	pointList = points
	var lineMesh = boxArrayMesh._make_from_array(pointList,spacing)
	collisionShape.shape = lineMesh.create_trimesh_shape()
	multiMesh.instance_count = pointList.size()
	for i in range(pointList.size()):
		var pos = Vector3(pointList[i][0],pointList[i][2],pointList[i][1])
		multiMesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, pos))
		if i != 0:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,1.0))
		else:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.0))

func _set_state(index: int):
	for i in range(pointList.size()):
		if i == index:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,1.0))
		elif i < index and i != 0:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,5.0))
		elif i > index:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.1))
		elif i == 0:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
