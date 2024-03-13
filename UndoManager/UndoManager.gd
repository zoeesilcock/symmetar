class_name UndoManager
extends Node2D

# References
@export var document: Document

func undo() -> void:
	if len(document.state.diffs_applied) > 0:
		var latest_diff: DocumentStateDiff = document.state.diffs_applied.pop_back()
		document.state.apply_diff(latest_diff, true)
		document.state.diffs_undone.push_back(latest_diff)
		_sync_previous_state()

func redo() -> void:
	if len(document.state.diffs_undone) > 0:
		var latest_undone_diff: DocumentStateDiff = document.state.diffs_undone.pop_back()
		document.state.apply_diff(latest_undone_diff, false)
		document.state.diffs_applied.push_back(latest_undone_diff)
		_sync_previous_state()

func register_diff() -> void:
	var diff: DocumentStateDiff = document.state.calculate_diff()
	document.state.diffs_applied.push_back(diff)
	_sync_previous_state()

func _sync_previous_state() -> void:
	document.state.previous_elements = []
	for element: ElementState in document.state.elements:
		document.state.previous_elements.push_back(element.duplicate())

	document.state.previous_background_color = document.state.background_color
