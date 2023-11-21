class_name UndoManager
extends Node2D

# References
@export var document : Document

func undo():
	if len(document.state.diffs_applied) > 0:
		var latest_diff = document.state.diffs_applied.pop_back()
		document.state.apply_diff(latest_diff, true)
		document.state.diffs_undone.push_back(latest_diff)
		_sync_previous_state()

func redo():
	if len(document.state.diffs_undone) > 0:
		var latest_undone_diff = document.state.diffs_undone.pop_back()
		document.state.apply_diff(latest_undone_diff, false)
		document.state.diffs_applied.push_back(latest_undone_diff)
		_sync_previous_state()

func register_diff():
	var diff = document.state.calculate_diff()
	document.state.diffs_applied.push_back(diff)
	_sync_previous_state()

func _sync_previous_state():
	document.state.previous_elements = []
	for element in document.state.elements:
		document.state.previous_elements.push_back(element.duplicate())
