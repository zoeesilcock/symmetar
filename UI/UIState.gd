class_name UIState
extends Resource

# Data
@export var main_window_scale: float
@export var ui_is_visible: bool:
	set(value):
		if value != ui_is_visible:
			ui_is_visible = value
			ui_is_visible_changed.emit()

@export var any_slice_is_dragging: bool
@export var any_slice_is_rotating: bool
@export var any_slice_is_pivoting: bool
@export var any_slice_is_scaling: bool
@export var any_slice_is_highlighted: bool
@export var any_slice_is_busy: bool:
	get:
		return (
			any_slice_is_dragging or
			any_slice_is_rotating or
			any_slice_is_pivoting or
			any_slice_is_scaling
		)

@export var selected_items: Array[UISelection]
@export var main_selected_item: UISelection:
	get:
		if len(selected_items) > 0:
			return selected_items[0]
		else:
			return null

@export var background_color_picker_visible: bool
@export var slice_color_picker_visible: bool
@export var slice_outline_color_picker_visible: bool
@export var document_name: String
@export var document_is_dirty: bool:
	set(value):
		if value != document_is_dirty:
			document_is_dirty = value
			document_is_dirty_changed.emit()
@export var zoom: float:
	set(value):
		if value != zoom:
			zoom = value
			zoom_changed.emit()

# Signals
signal selection_changed
signal document_is_dirty_changed
signal ui_is_visible_changed
signal zoom_changed

func init() -> void:
	ui_is_visible = true
	any_slice_is_dragging = false
	document_name = "Untitled.smtr"

#region Selection
func set_selection(selection: UISelection) -> void:
	selected_items = [selection]
	selection_changed.emit()

func toggle_selection(selection: UISelection) -> void:
	if is_selected(selection):
		remove_selection(selection)
	else:
		if is_element_selected(selection):
			remove_element_selection(selection)

		add_selection(selection)

func add_selection(selection: UISelection) -> void:
	if !is_selected(selection) and !is_element_selected(selection):
		selected_items.append(selection)
		selection_changed.emit()

func remove_selection(selection: UISelection) -> void:
	selected_items = selected_items.filter(func(item: UISelection) -> bool:
		return !item.equals(selection)
	)
	selection_changed.emit()

func remove_element_selection(selection: UISelection) -> void:
	selected_items = selected_items.filter(func(item: UISelection) -> bool:
		return item.element_index != selection.element_index
	)
	selection_changed.emit()

func clear_selection() -> void:
	selected_items = []
	selection_changed.emit()

func is_selected(selection: UISelection) -> bool:
	for item: UISelection in selected_items:
		if item.equals(selection):
			return true

	return false

func is_element_selected(selection: UISelection) -> bool:
	for item: UISelection in selected_items:
		if item.element_index == selection.element_index:
			return true

	return false

func fix_missing_element_in_selection(max_element_index: int) -> void:
	selected_items = selected_items.filter(func(item: UISelection) -> bool:
		return item.element_index < max_element_index
	)
	selection_changed.emit()

func fix_missing_slice_in_selection(element_index: int, max_slice_index: int) -> void:
	for selected_item: UISelection in selected_items:
		if selected_item.element_index == element_index and selected_item.slice_index > max_slice_index:
			selected_item.slice_index = max_slice_index
			selection_changed.emit()
			return
#endregion
