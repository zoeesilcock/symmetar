class_name DocumentStateDiff
extends Resource

@export var element_count_change : int
@export var background_color_change : Color
@export var element_changes : Array[ElementState]

func _init(
		p_element_count_change : int = 0,
		p_element_changes : Array[ElementState] = [],
		p_background_color_change : Color = Color.BLACK) -> void:
	element_count_change = p_element_count_change
	background_color_change = p_background_color_change
	element_changes = p_element_changes
