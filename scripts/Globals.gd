
extends Node

var zoom_lockout = false
var spacing = 1

var coords = {
	"X" : 0,
	"Y" : 1,
	"Z" : 2
}

var style = {
	"EMPTY": 0,
	"SURFACE" : 1,
	"SELECTED" : 2,
	"STARTING" : 3
}

func _get_mouse_position() -> Dictionary:
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	return {
		"origin": origin,
		"direction": direction
	}
	
func _mouse_ray_trace_plane(plane: Plane) -> Vector3:
	var mouse_pos = Globals._get_mouse_position()
	var intersection = plane.intersects_ray(mouse_pos.origin, mouse_pos.direction)
	if intersection != null:
		return intersection
	else:
		return Vector3(-1000,-1000,-1000)

func _mouse_get_clicked(predicate: Callable) -> Dictionary:
	var mouse_pos = Globals._get_mouse_position()
	var origin = mouse_pos.origin
	var direction = mouse_pos.direction
	var max_distance = 100
	var excluded = []
	var space_state = get_viewport().get_world_3d().direct_space_state
	while true:
		var query = PhysicsRayQueryParameters3D.create(
			origin,
			origin + direction.normalized() * max_distance
			)
		query.exclude = excluded
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			break
		var candidate = result.collider
		if predicate.call(candidate):
			return result
		excluded.append(result.rid)
	return {}
	
	
func _mouse_get_clicked_character() -> Dictionary:
	return _mouse_get_clicked(
		func(node):
			return node.is_in_group("Characters")
	)
	
func _mouse_get_clicked_line() -> Dictionary:
	return _mouse_get_clicked(
		func(node):
			return node.is_in_group("Lines")
	)

func _line_get_clicked(line: Node) -> Dictionary:
	var getClicked = _mouse_get_clicked(
		func(node):
			return node == line
	)
	var pos = Vector3(-1,-1,-1)
	if !getClicked.is_empty():
		pos = getClicked.position
	return {
		"check": getClicked,
		"position": pos
	}

func _grid_dist(p1: Array[int], p2: Array[int]) -> float:
	var a0 = (p1[0] - p2[0])**2
	var a1 = (p1[1] - p2[1])**2
	var a2 = (p1[2] - p2[2])**2
	return sqrt(a0 + a1 + a2)
	
func _diagonal_dist(p1: Array[int], p2: Array[int]) -> int:
	var a0 = abs(p1[0] - p2[0])
	var a1 = abs(p1[1] - p2[1])
	var a2 = abs(p1[2] - p2[2])
	return max(a0,a1,a2)
