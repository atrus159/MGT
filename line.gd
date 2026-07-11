extends StaticBody3D


@onready var multiMeshInstance = $MultiMeshInstance3D
@onready var collisionShape = $CollisionShape3D
var spacing = Globals.spacing
var pointList
const AOE_material = preload("res://assets/shaders/AOE_shader_material.tres")
var multiMesh
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiMesh = MultiMesh.new()
	multiMesh.transform_format = MultiMesh.TRANSFORM_3D
	#multiMesh.use_custom_data = true
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
