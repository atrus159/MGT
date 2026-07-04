
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
