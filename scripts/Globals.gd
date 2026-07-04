
extends Node

var zoom_lockout = false

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

func _mouse_get_clicked_character() -> Node:
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
		if candidate.is_in_group("Characters"):
			return candidate
		excluded.append(result.rid)
	return null
