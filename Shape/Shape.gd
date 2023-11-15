class_name Shape
extends Node2D

# References
@export var ui_state : UIState
@export var polygon : Polygon2D
@export var selection_node : Node2D

# Settings
@export var highlight_brighten : float
@export var element_index : int
@export var slice_index : int

# Signals
signal position_changed
signal selected

# Internal
var is_selected
var is_dragging
var drag_offset
var view_to_world
var original_color
var highlighted_color
var viewport

func _ready():
	view_to_world = get_canvas_transform().affine_inverse()
	original_color = polygon.color
	highlighted_color = polygon.color
	highlighted_color.v += highlight_brighten
	viewport = get_viewport()

	ui_state.selection_changed.connect(_on_selection_changed)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var world_position = view_to_world * event.position
		if not ui_state.any_shape_is_dragging and _is_point_in_shape(world_position - position):
			if not is_dragging and event.pressed:
				viewport.set_input_as_handled()
				drag_offset = world_position - position
				_start_dragging()

		if is_dragging and not event.pressed:
			viewport.set_input_as_handled()
			_end_dragging()

	if is_dragging && event is InputEventMouseMotion:
		viewport.set_input_as_handled()
		_update_dragging(event)

func _start_dragging():
	selected.emit(slice_index)
	ui_state.any_shape_is_dragging = true
	is_dragging = true
	polygon.color = highlighted_color

func _update_dragging(event):
	position = view_to_world * (event.position - drag_offset)
	position_changed.emit(slice_index)

func _end_dragging():
	selected.emit(slice_index)
	ui_state.any_shape_is_dragging = false
	is_dragging = false
	polygon.color = original_color

func _set_selection(enabled : bool):
	is_selected = enabled
	selection_node.visible = enabled

func _on_selection_changed():
	_set_selection(
		ui_state.selected_element_index == element_index and
		ui_state.selected_slice_index == slice_index
	)

func _is_point_in_shape(point):
	return Geometry2D.is_point_in_polygon(
		point,
		polygon.get_polygon() * Transform2D(-rotation, Vector2.ZERO)
	)
