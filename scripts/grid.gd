
extends MultiMeshInstance3D

@export var length = 8
@export var width = 8
@export var height = 6
@export var spacing = 1

enum coords {
	X,
	Y,
	Z
}

enum style {
	empty = 0,
	whiteBorder = 1,
	blackBorder = 2,
	solid = 3
}

enum face {
	up = 0,
	down = 1,
	left = 2,
	right = 3,
	forward =4,
	back = 5
}


const grid_material = preload("res://assets/shaders/grid_shader_material.tres")
const bounding_material = preload("res://assets/shaders/bounding_shader_material.tres")
var gridCells: Array = []
var startingPoint = Vector3(-(length*spacing)/2,-(height*spacing)/4,-(width*spacing)/2)

@onready var BoundingBox = $BoundingBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	BoundingBox.mesh = boxArrayMesh.make(spacing*length,spacing*width,spacing*height)
	BoundingBox.mesh.surface_set_material(0, bounding_material)
	BoundingBox.position = startingPoint
	
	gridCells.resize(length)
	for i in range(length):
		gridCells[i] = []
		gridCells[i].resize(width)
		for j in range(width):
			gridCells[i][j] = []
			gridCells[i][j].resize(height)
			for k in range(height):
				gridCells[i][j][k] = gridCell.new()
	
	
	var cell_mesh = boxArrayMesh.make(spacing,spacing,spacing)
	cell_mesh.surface_set_material(0, grid_material)
	
	var mm = MultiMesh.new()
	mm.transform_format =MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = cell_mesh
	mm.instance_count = length * width * height
	
	var i := 0
	
	for x in range(length):
		for z in range(width):
			for y in range(height):
				var transform = Transform3D.IDENTITY
				transform.origin = Vector3(
					x * spacing,
					y * spacing,
					z * spacing
				)
				transform.origin += startingPoint
				
				mm.set_instance_transform(i, transform)
				i += 1
	
	multimesh = mm
	
func _get_position_index(point: Array[int]) -> int:
	return point[2] + height * point[1] + height * width * point[0]	

func _set_data_state(point: Array[int], cell_style: style, faces: Array[int] = [0,0,0,0,0,0], alpha: float = 1.0):
	var styleMask = cell_style
	var facesMask = 2**0*faces[0] + 2**1*faces[1] + 2**2*faces[2] + 2**3*faces[3] + 2**4*faces[4] + 2**5*faces[5]
	var alphaMask = alpha
	multimesh.set_instance_custom_data(_get_position_index(point),Color(styleMask / 255.0, facesMask/63.0, 0.0, alphaMask/255.0))
	
func _clear_data_states():
	for i in range(length):
		for j in range(width):
			for k in range(height):
				_set_data_state([i,j,k], style.empty)

func _set_data_states_plane(planeHeight: int):
	for i in range(length):
		for j in range(width):
			_set_data_state([i,j,planeHeight], style.blackBorder,[0,1,0,0,0,0])
				
	
func _to_grid_space(point: Vector3) -> Array[int]:
	var convertedPoint = point - startingPoint
	convertedPoint /= spacing
	convertedPoint = floor(convertedPoint)
	return [int(convertedPoint.x), int(convertedPoint.z), int(convertedPoint.y)]
	
func _to_world_space(point: Array[int]) -> Vector3:
	var worldPoint = Vector3(point[0],point[2],point[1])
	worldPoint *= spacing
	worldPoint += startingPoint
	return worldPoint
	
func _in_bounds(point: Array[int]) -> bool:
	if point[0] >= 0 and point[0] < length:
		if point[1] >= 0 and point[1] < width:
			if point[2] >= 0 and point[2] < height:
				return true
	return false

func _get_mouse_plane_coords(gridPlane: Dictionary) -> Array[int]:
	var plane
	match gridPlane.direction:
		coords.X:
			var worldCoord = _to_world_space([gridPlane.distance,0,0])
			worldCoord.x += spacing/2.0
			plane = Plane(Vector3.RIGHT, worldCoord.x)
		coords.Y:
			var worldCoord = _to_world_space([0,gridPlane.distance,0])
			worldCoord.z += spacing/2.0
			plane = Plane(Vector3.BACK, worldCoord.z)
		coords.Z:
			var worldCoord = _to_world_space([0,0,gridPlane.distance])
			worldCoord.y += spacing/2.0
			plane = Plane(Vector3.UP, worldCoord.y)
	var ray_trace_point = _to_grid_space(Globals._mouse_ray_trace_plane(plane))
	if _in_bounds(ray_trace_point):
		return ray_trace_point
	return [-1,-1,-1]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
