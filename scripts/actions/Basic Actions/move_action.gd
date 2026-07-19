class_name move_action extends action

func _init():
	mode = selectorMove.new()

func _make_queue_data(selectorData: Dictionary) -> Dictionary:
	return {
		"action": self,
		"character": character,
		"actionCost": actionCost,
		"startingPos": field._to_grid_space(character.position),
		"targetPos": selectorData.pos
	}
	
func _perform_queue_data(queueData: Dictionary):
	if field._to_grid_space(character.position) == queueData.startingPos:
		if field.gridCells[queueData.targetPos[0]][queueData.targetPos[1]][queueData.targetPos[2]].contents == null:
			field._move_character(character,queueData.targetPos)
