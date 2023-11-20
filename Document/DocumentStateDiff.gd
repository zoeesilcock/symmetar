class_name DocumentStateDiff
extends Resource

@export var element_count_change : int
@export var element_changes = [] # : ElementState

func _init(count_change, changes):
	element_count_change = count_change
	element_changes = changes
