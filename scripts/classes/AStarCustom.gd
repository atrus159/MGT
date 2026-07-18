class_name AStarCustom
extends AStar3D


func _compute_cost(u, v):
	var u_pos = get_point_position(u)
	var v_pos = get_point_position(v)
	var adjacent = 1
	var diagonal = 1.4
	var doubleDiagonal = 1.7
	var sameX = u_pos.x == v_pos.x
	var sameY = u_pos.y == v_pos.y
	var sameZ = u_pos.z == v_pos.z
	if sameX:
		if sameY or sameZ:
			return adjacent
		else:
			return diagonal
	elif sameY:
		if sameX or sameZ:
			return adjacent
		else:
			return diagonal
	elif sameZ:
		if sameX or sameY:
			return adjacent
		else:
			return diagonal
	else:
		return doubleDiagonal

func _estimate_cost(u,v):
	return _compute_cost(u,v)
	
func _calc_path_cost(path: Array) -> float:
	var cost = 0.0
	for i in range(1,path.size()):
		cost += _compute_cost(path[i-1],path[i])
	return cost
