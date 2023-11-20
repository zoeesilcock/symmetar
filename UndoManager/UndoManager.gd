class_name UndoManager
extends Node2D

# References
@export var document : Document

func undo():
	if len(document.state.diffs_applied) > 0:
		var latest_diff = document.state.diffs_applied.pop_back()
		_apply_diff(latest_diff, true)
		document.state.diffs_undone.push_back(latest_diff)
		_sync_previous_state()

func redo():
	if len(document.state.diffs_undone) > 0:
		var latest_undone_diff = document.state.diffs_undone.pop_back()
		_apply_diff(latest_undone_diff, false)
		document.state.diffs_applied.push_back(latest_undone_diff)
		_sync_previous_state()

func register_diff():
	var diff = _calculate_diff()
	document.state.diffs_applied.push_back(diff)
	_sync_previous_state()

func _sync_previous_state():
	document.state.previous_elements = []
	for element in document.state.elements:
		document.state.previous_elements.push_back(element.duplicate())

func _fill_empty_slots():
	for i in len(document.state.elements):
		if document.state.elements[i] == null:
			document.state.elements[i] = ElementState.new()

func _calculate_diff() -> DocumentStateDiff:
	var diff = []
	var count_change = len(document.state.elements) - len(document.state.previous_elements)

	for index in len(document.state.elements):
		var element = document.state.elements[index]
		var previous_element = ElementState.new()
		var element_diff = ElementState.new()

		if index < len(document.state.previous_elements):
			previous_element = document.state.previous_elements[index]

		element_diff.index = element.index - previous_element.index
		element_diff.radius = element.radius - previous_element.radius
		element_diff.slice_count = element.slice_count - previous_element.slice_count
		element_diff.slice_rotation = element.slice_rotation - previous_element.slice_rotation
		element_diff.slice_position = element.slice_position - previous_element.slice_position

		diff.push_back(element_diff)

	return DocumentStateDiff.new(count_change, diff)

func _apply_diff(diff : DocumentStateDiff, reverse : bool):
	var current_count = len(document.state.elements)
	var direction = 1
	if reverse: direction = -1

	if (diff.element_count_change != 0):
		document.state.elements.resize(current_count + diff.element_count_change * direction)
		_fill_empty_slots()

	for index in len(diff.element_changes):
		if index < len(document.state.elements):
			document.state.elements[index].index += diff.element_changes[index].index * direction
			document.state.elements[index].radius += diff.element_changes[index].radius * direction
			document.state.elements[index].slice_count += diff.element_changes[index].slice_count * direction
			document.state.elements[index].slice_rotation += diff.element_changes[index].slice_rotation * direction
			document.state.elements[index].slice_position += diff.element_changes[index].slice_position * direction

	document.state.elements_count_changed.emit(diff.element_count_change * direction)
