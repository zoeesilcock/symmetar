class_name UISelection
extends Resource

@export var element_index: int
@export var slice_index: int

func _init(p_element_index: int, p_slice_index: int) -> void:
	element_index = p_element_index
	slice_index = p_slice_index

func equals(other_selection: UISelection) -> bool:
	return (
		element_index == other_selection.element_index and
		slice_index == other_selection.slice_index
	)
