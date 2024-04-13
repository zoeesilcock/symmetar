class_name DocumentStateDiff
extends Resource

@export var element_count_change: int
@export var element_diffs: Array[ElementStateDiff]
@export var background_color_change: Color

func _init(
		p_element_count_change: int=0,
		p_element_diffs: Array[ElementStateDiff]=[],
		p_background_color_change: Color=Color.BLACK) -> void:
	element_count_change = p_element_count_change
	element_diffs = p_element_diffs
	background_color_change = p_background_color_change
