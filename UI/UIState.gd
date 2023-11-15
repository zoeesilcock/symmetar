class_name UIState
extends Resource

# Data
@export var any_shape_is_dragging : bool
@export var selected_element_index : int:
	set(value):
		selected_element_index = value
		selection_changed.emit()
@export var selected_slice_index : int:
	set(value):
		selected_slice_index = value
		selection_changed.emit()

# Signals
signal selection_changed

func _init():
	any_shape_is_dragging = false
	selected_element_index = -1
	selected_slice_index = -1
