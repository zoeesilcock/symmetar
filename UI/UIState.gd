class_name UIState
extends Resource

# Data
@export var any_slice_is_dragging : bool
@export var any_slice_is_rotating : bool
@export var any_slice_is_pivoting : bool
@export var any_slice_is_scaling : bool

@export var any_slice_is_busy : bool:
	get:
		return (
			any_slice_is_dragging or
			any_slice_is_rotating or
			any_slice_is_pivoting or
			any_slice_is_scaling
		)

@export var selected_element_index : int
@export var selected_slice_index : int
@export var slice_color_picker_visible : bool

# Signals
signal selection_changed

func _init() -> void:
	any_slice_is_dragging = false
	selected_element_index = -1
	selected_slice_index = -1

func set_selection(element_index : int, slice_index : int) -> void:
	selected_element_index = element_index
	selected_slice_index = slice_index
	selection_changed.emit()
