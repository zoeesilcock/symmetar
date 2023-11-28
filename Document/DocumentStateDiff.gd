class_name DocumentStateDiff
extends Resource

@export var element_count_change : int
@export var element_changes = [] # : ElementState

func _init(p_element_count_change, p_element_changes):
	element_count_change = p_element_count_change
	element_changes = p_element_changes
