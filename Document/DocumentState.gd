class_name DocumentState
extends Resource

# Data
@export var elements = [] # : ElementState
@export var previous_elements = [] # : ElementState

# Diff
@export var diffs_applied = [] # : DocumentStateDiff
@export var diffs_undone = [] # : DocumentStateDiff

# Signals
signal elements_count_changed

func calculate_diff() -> DocumentStateDiff:
	var diff : Array[ElementState] = []
	var count_change = len(elements) - len(previous_elements)

	for index in len(elements):
		var element = elements[index]
		var previous_element = ElementState.new()

		if index < len(previous_elements):
			previous_element = previous_elements[index]

		diff.push_back(element.get_diff(previous_element))

	return DocumentStateDiff.new(count_change, diff)

func apply_diff(diff : DocumentStateDiff, reverse : bool) -> void:
	var current_count = len(elements)
	var direction = 1
	if reverse: direction = -1

	if (diff.element_count_change != 0):
		elements.resize(current_count + diff.element_count_change * direction)
		_fill_empty_slots()

	for index in len(diff.element_changes):
		if index < len(elements):
			elements[index].apply_diff(diff.element_changes[index], direction)

	elements_count_changed.emit(diff.element_count_change * direction)

func _fill_empty_slots() -> void:
	for i in len(elements):
		if elements[i] == null:
			elements[i] = ElementState.new()
