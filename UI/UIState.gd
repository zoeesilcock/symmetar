class_name UIState
extends Resource

# Data
@export var any_shape_is_dragging : bool
@export var selected_element_index : int
@export var selected_slice_index : int

# Signals
signal selection_changed

func _init():
	any_shape_is_dragging = false
	selected_element_index = -1
	selected_slice_index = -1

func set_selection(element_index : int, slice_index : int):
	selected_element_index = element_index
	selected_slice_index = slice_index
	selection_changed.emit()
