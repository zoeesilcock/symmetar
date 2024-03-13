class_name DocumentState
extends Resource

# Data
@export var elements: Array[ElementState]
@export var previous_elements: Array[ElementState]
@export var background_color: Color:
	set(value):
		if value != background_color:
			background_color = value
			background_color_changed.emit()
@export var previous_background_color: Color
@export var zoom: float:
	set(value):
		if value != zoom:
			zoom = value
			zoom_changed.emit()
@export var previous_zoom: float
@export var pan_position: Vector2:
	set(value):
		if value != pan_position:
			pan_position = value
			pan_position_changed.emit()
@export var previous_pan_position: Vector2

# Diff
@export var diffs_applied: Array[DocumentStateDiff]
@export var diffs_undone: Array[DocumentStateDiff]

# Signals
signal element_count_changed
signal background_color_changed
signal zoom_changed
signal pan_position_changed

# Constants
const DEFAULT_BACKGROUND_COLOR: Color = Color("#a02424")

func _init(
		p_background_color: Color=DEFAULT_BACKGROUND_COLOR,
		p_zoom: float=1,
		p_pan_position: Vector2=Vector2.ZERO) -> void:
	background_color = p_background_color
	previous_background_color = background_color
	zoom = p_zoom
	previous_zoom = zoom
	pan_position = p_pan_position
	previous_pan_position = pan_position

func calculate_diff() -> DocumentStateDiff:
	var diff: Array[ElementState] = []
	var count_change: int = len(elements) - len(previous_elements)
	var element_count: int = max(len(elements), len(previous_elements))
	var background_color_change: Color = Color.BLACK

	for index: int in element_count:
		var element: ElementState = ElementState.empty()
		var previous_element: ElementState = ElementState.empty()

		if index < len(elements):
			element = elements[index]

		if index < len(previous_elements):
			previous_element = previous_elements[index]

		diff.push_back(element.get_diff(previous_element))

	background_color_change.r = background_color.r - previous_background_color.r
	background_color_change.g = background_color.g - previous_background_color.g
	background_color_change.b = background_color.b - previous_background_color.b

	return DocumentStateDiff.new(count_change, diff, background_color_change)

func apply_diff(diff: DocumentStateDiff, reverse: bool) -> void:
	var current_count: int = len(elements)
	var direction: int = 1
	if reverse: direction = -1

	if diff.element_count_change != 0:
		elements.resize(current_count + diff.element_count_change * direction)
		_fill_empty_slots()

	for index: int in len(diff.element_changes):
		if index < len(elements):
			elements[index].apply_diff(diff.element_changes[index], direction)

	if diff.element_count_change != 0:
		element_count_changed.emit()

	var new_background_color: Color = Color(
		background_color.r + diff.background_color_change.r * direction,
		background_color.g + diff.background_color_change.g * direction,
		background_color.b + diff.background_color_change.b * direction
	)

	background_color = new_background_color

func _fill_empty_slots() -> void:
	for index: int in len(elements):
		if elements[index] == null:
			elements[index] = ElementState.empty()
