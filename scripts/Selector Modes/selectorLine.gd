class_name selectorLine extends selectorMode

var lines = []
var selectedLine = {}
var linearDeselectTimer = 0
var lineCenter : Array[int] = [0,0,0]
var dist = 0


func _calc(selector: Node) -> Dictionary:
	var newDist = dist
	var tempLine = selectedLine
	if tempLine.is_empty():
		tempLine = Globals._mouse_get_clicked_line()
	else:
		var isClicked = Globals._line_get_clicked(tempLine.collider)
		if isClicked.check:
			var lineCoord = tempLine.collider._get_nearest(isClicked.position)
			newDist = Globals._diagonal_dist(lineCenter,lineCoord)
			linearDeselectTimer = 0
		else:
			var antiLine = _get_anti_line()
			isClicked = Globals._line_get_clicked(antiLine)
			if isClicked.check:
				tempLine = {
					"collider": antiLine,
					"position": isClicked.position
				}
				linearDeselectTimer = 0
			else:
				linearDeselectTimer += selector.delta_t
				if linearDeselectTimer >= 0.1:
					tempLine = {}
					linearDeselectTimer = 0
	
	return {
		"dist": newDist,
		"selectedLine": tempLine
	}

func _update(selector: Node, result: Dictionary) -> Dictionary:
	dist = result.dist
	selectedLine = result.selectedLine
	if !selectedLine.is_empty():
		for line in lines:
			line._set_state(-1)
		selectedLine.collider._set_state(dist)
	else:
		for line in lines:
			line._set_state(-2)
	
	if Input.is_action_just_pressed("Select"):
		if !selectedLine.is_empty() and selectedLine.collider.pointList.size() > 0:
			return {
				"pos": selectedLine.collider.pointList[dist]
			}
		else:
			return{
				"pos": [-1,-1,-1]
			}
	return {}


func _start(selector: Node) -> Dictionary:
	lineCenter = selector.field._to_grid_space(selector.selectedChar.position)
	lines.clear()
	for i in range(-1,2):
		for j in range(-1,2):
			for k in range(-1,2):
				var newLine = selector.field._make_line(lineCenter, [i,j,k] as Array[int])
				if newLine.instance != null:
					lines.append(newLine.instance)
	Globals.zoom_lockout = false
	selector.selection.hide()
	return {}
	
		
func _end(selector: Node) -> Dictionary:
	for line in lines:
		line.queue_free()
	selectedLine = {}
	return {}


func _get_anti_line() -> Node:
	for line in lines:
		if line.pointList.size() <= 1:
			continue
		var p1 = line.pointList[1]
		var p2 = selectedLine.collider.pointList[1]
		if p1[0] - lineCenter[0] == lineCenter[0] - p2[0]:
			if p1[1] - lineCenter[1] == lineCenter[1] - p2[1]:
				if p1[2] - lineCenter[2] == lineCenter[2] - p2[2]:
					return line
	return null
