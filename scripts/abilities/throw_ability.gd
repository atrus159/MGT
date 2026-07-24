class_name throw_ability extends ability

func _init():
	mode = selectorGravity.new()

func _make_queue_data(selectorData: Dictionary) -> Dictionary:
	return {
		"ability": self,
		"character": character,
		"actionCost": actionCost,
		"startingPos": field._to_grid_space(character.position),
		"targetPos": selectorData.pos
	}
	
func _perform_queue_data(queueData: Dictionary):
	#if field._to_grid_space(character.position) == queueData.startingPos:
		#if field.gridCells[queueData.targetPos[0]][queueData.targetPos[1]][queueData.targetPos[2]].contents == null:
			field._move_character(character,queueData.targetPos)
