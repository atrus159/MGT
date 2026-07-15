extends StaticBody3D


@onready var multiMeshInstance = $MultiMeshInstance3D
@onready var collisionShape = $CollisionShape3D
@onready var field = get_tree().current_scene.get_node("PlayingField")

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
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.3))
		elif i > index:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.1))
		elif i == 0:
			multiMesh.set_instance_custom_data(i,Color(0.0,0.0,0.0,0.0))

func _get_nearest(point: Vector3) -> Array[int]:
	for i in range(pointList.size()):
		var curPoint = pointList[i]
		var worldPoint = field._to_world_space(curPoint)
		if _check_on_cell(point,worldPoint):
			return curPoint
	return [-1,-1,-1]
	
func _check_on_cell(point: Vector3, basePoint: Vector3) -> bool:
	if point.x >= basePoint.x-0.1 and point.x <= basePoint.x + 1.1:
		if point.y >= basePoint.y-0.1 and point.y <= basePoint.y + 1.1:
			if point.z >= basePoint.z-0.1 and point.z <= basePoint.z + 1.1:
				return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
