
extends MultiMeshInstance3D

@export var length = 8
@export var width = 8
@export var height = 6
@export var spacing = Globals.spacing

enum coords {
	X,
	Y,
	Z
}

enum style {
	empty = 0,
	surface = 1,
	selected = 2,
	starting = 3
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
const AOE_material = preload("res://assets/shaders/AOE_shader_material.tres")
const line_template = preload("res://assets/scenes/line.tscn")
var gridCells: Array = []
var startingPoint = Vector3(-(length*spacing)/2,-(height*spacing)/4,-(width*spacing)/2)

var characterTemplate = preload("res://assets/scenes/character.tscn")

@onready var BoundingBox = $BoundingBox
@onready var CharacterContainer = get_tree().current_scene.get_node("Characters")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	BoundingBox.mesh = boxArrayMesh.make(spacing*length,spacing*width,spacing*height)
	BoundingBox.mesh.surface_set_material(0, bounding_material)
	BoundingBox.position = startingPoint
	var grey = Color.GRAY
	grey.a = 0.5
	BoundingBox.set_instance_shader_parameter("wire_color", grey)
	
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
	
	
func _make_range_mesh(point: Array[int], range: int) -> Dictionary:
	var pointList = []
	for i in range(-range, range+1):
		for j in range(-range, range+1):
			for k in range(-range, range+1):
				if sqrt(i**2 + j**2 + k**2)<= range:
					var newPoint: Array[int] = [point[0]+i,point[1]+j,point[2]+k]
					if _in_bounds(newPoint):
						pointList.append(newPoint)
	
	var rangeMesh = boxArrayMesh._make_from_array(pointList,spacing)
	var rangeMeshInstance = MeshInstance3D.new()
	rangeMeshInstance.mesh = rangeMesh
	rangeMeshInstance.position = startingPoint
	rangeMeshInstance.material_override = AOE_material
	add_child(rangeMeshInstance)
	return {
		"array": pointList,
		"instance": rangeMeshInstance
	}
	
func _make_line(point: Array[int], direction: Array[int]) -> Dictionary:
	var pointList : = []
	if direction == [0,0,0]:
		return {
			"array": pointList,
			"instance": null
		}
	var curPoint : Array[int] = point
	while _in_bounds(curPoint):
		pointList.append(curPoint)
		curPoint = [curPoint[0]+direction[0],curPoint[1]+direction[1],curPoint[2]+direction[2]] as Array[int]
	var line = line_template.instantiate()
	add_child(line)
	line._initiate(pointList)
	line.position = startingPoint
	return {
		"array": pointList,
		"instance": line
	}

	
func _place_character(point: Array[int]):
	var newChar = characterTemplate.instantiate()
	CharacterContainer.add_child(newChar)
	gridCells[point[0]][point[1]][point[2]].set_contents(newChar)
	newChar.position = _to_world_space(point)


func _move_character(character: Node, point: Array[int]):
	var charPosition = _to_grid_space(character.position)
	gridCells[charPosition[0]][charPosition[1]][charPosition[2]].set_contents(null)
	gridCells[point[0]][point[1]][point[2]].set_contents(character)
	character.position = _to_world_space(point)
	
func _get_position_index(point: Array[int]) -> int:
	return point[2] + height * point[1] + height * width * point[0]	

func _set_data_state(point: Array[int], cell_style: style, faces: Array[int] = [0,0,0,0,0,0], alpha: float = 1.0):
	var styleMask = cell_style
	var facesMask = 2**0*faces[0] + 2**1*faces[1] + 2**2*faces[2] + 2**3*faces[3] + 2**4*faces[4] + 2**5*faces[5]
	multimesh.set_instance_custom_data(_get_position_index(point),Color(styleMask / 8.0, facesMask/63.0, 0.0, alpha))
	
func _clear_data_states():
	for i in range(length):
		for j in range(width):
			for k in range(height):
				_set_data_state([i,j,k], style.empty)

func _establish_building(x:int,y:int,z:int,l:int,w:int,h:int, building: Node) -> bool:
	for i in range(x,x+l):
		for j in range(y,y+w):
			for k in range(z,z+h):
				if !_in_bounds([i,j,k] as Array[int]):
					return false
	for i in range(x,x+l):
		for j in range(y,y+w):
			for k in range(z,z+h):
				gridCells[i][j][k].building_inside = building
	return true
					
func _set_data_states_plane(gridPlane: Dictionary, setStyle: style, range: Array = []):
	var mainAlpha = 1
	var outsideAlpha = 0.2

	match gridPlane.direction:
		coords.X:
			for j in range(width):
				for k in range(height):
					var alpha = mainAlpha
					if range != []:
						if !range.has([gridPlane.distance,j,k]):
							alpha = outsideAlpha
					_set_data_state([gridPlane.distance,j,k], setStyle,[0,0,1,0,0,0], alpha)
		coords.Y:
			for i in range(length):
				for k in range(height):
					var alpha = mainAlpha
					if range != []:
						if !range.has([i,gridPlane.distance,k]):
							alpha = outsideAlpha
					_set_data_state([i,gridPlane.distance,k], setStyle,[0,0,0,0,0,1], alpha)
		coords.Z:
			for i in range(length):
				for j in range(width):
					var alpha = mainAlpha
					if range != []:
						if !range.has([i,j,gridPlane.distance]):
							alpha = outsideAlpha
					_set_data_state([i,j,gridPlane.distance], setStyle,[0,1,0,0,0,0], alpha)

	
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
				if gridCells[point[0]][point[1]][point[2]].building_inside == null:
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
			
