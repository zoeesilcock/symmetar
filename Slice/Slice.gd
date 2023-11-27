class_name Slice
extends Node2D

# References
@export var ui_state : UIState
@export var polygon : Polygon2D
@export var rotation_polygon : Polygon2D
@export var selection_node : Node2D
@export var rotation_selection_node : Node2D
@export var debug_slice_index : Label

# Settings
@export var highlight_brighten : float
@export var element_index : int
@export var slice_index : int

# Signals
signal selected
signal position_changed
signal dragging_ended
signal rotation_changed
signal rotating_ended

# Internal
var is_selected

var is_dragging
var drag_offset

var is_rotating
var initial_theta
var initial_rotation

var view_to_world
var original_color
var highlighted_color
var viewport

func init(slice_position : Vector2, slice_rotation : float, index : int, element_index : int, color : Color):
	name = "Slice" + str(index)
	position = slice_position
	rotation = slice_rotation
	set_color(color)

	slice_index = index
	self.element_index = element_index
	debug_slice_index.text = str(slice_index)

func _ready():
	view_to_world = get_canvas_transform().affine_inverse()
	viewport = get_viewport()

	ui_state.selection_changed.connect(_on_selection_changed)

func set_color(color : Color):
	original_color = color
	polygon.color = color
	highlighted_color = color
	highlighted_color.v += highlight_brighten

func _unhandled_input(event : InputEvent):
	if event is InputEventMouseButton || event is InputEventMouseMotion:
		var world_position = view_to_world * event.position
		var cursor_in_slice = _is_point_in_slice(world_position - position)
		var any_slice_busy = ui_state.any_slice_is_dragging || ui_state.any_slice_is_rotating

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			# Dragging
			if event.pressed and not any_slice_busy and cursor_in_slice:
				viewport.set_input_as_handled()
				_start_dragging(world_position)
			elif not event.pressed and is_dragging:
				viewport.set_input_as_handled()
				_end_dragging()

			# Rotating
			if is_selected:
				if event.pressed and not any_slice_busy and not cursor_in_slice and \
					_is_point_in_rotation_area(world_position - position):
						viewport.set_input_as_handled()
						_start_rotating(world_position)
				elif not event.pressed and is_rotating:
					viewport.set_input_as_handled()
					_end_rotating()

		if is_selected and event is InputEventMouseMotion:
			if is_dragging:
				viewport.set_input_as_handled()
				_update_dragging(event)

				if not selection_node.visible:
					_show_selection()
			elif is_rotating:
				viewport.set_input_as_handled()
				_update_rotating(event, world_position)

				if not rotation_selection_node.visible:
					_show_rotation_selection()
			else:
				var cursor_in_rotation_area = not cursor_in_slice and _is_point_in_rotation_area(world_position - position)

				if selection_node.visible and cursor_in_rotation_area:
					_show_rotation_selection()
				elif rotation_selection_node.visible and not cursor_in_rotation_area:
					_show_selection()

func _show_selection():
	selection_node.visible = true
	rotation_selection_node.visible = false

func _show_rotation_selection():
	selection_node.visible = false
	rotation_selection_node.visible = true

func _hide_selection():
	selection_node.visible = false
	rotation_selection_node.visible = false

func _start_dragging(world_position : Vector2):
	selected.emit(slice_index)

	drag_offset = world_position - position
	ui_state.any_slice_is_dragging = true
	is_dragging = true
	polygon.color = highlighted_color

func _update_dragging(event : InputEvent):
	position = view_to_world * (event.position - drag_offset)
	position_changed.emit(slice_index)

func _end_dragging():
	ui_state.any_slice_is_dragging = false
	is_dragging = false
	polygon.color = original_color
	dragging_ended.emit(slice_index)

func _start_rotating(world_position : Vector2):
	var relative_mouse_position = world_position - position
	initial_rotation = rotation
	initial_theta = atan2(relative_mouse_position.y, relative_mouse_position.x)
	ui_state.any_slice_is_rotating = true
	is_rotating = true
	polygon.color = highlighted_color

func _update_rotating(_event : InputEvent, world_position : Vector2):
	var relative_mouse_position = world_position - position
	var theta = atan2(relative_mouse_position.y, relative_mouse_position.x)

	rotation = (initial_rotation - initial_theta) + theta
	rotation_changed.emit(slice_index)

func _end_rotating():
	ui_state.any_slice_is_rotating = false
	is_rotating = false
	polygon.color = original_color
	rotating_ended.emit(slice_index)

func _set_selection(enabled : bool):
	is_selected = enabled

	if enabled:
		_show_selection()
	else:
		_hide_selection()

func _on_selection_changed():
	_set_selection(
		ui_state.selected_element_index == element_index and
		ui_state.selected_slice_index == slice_index
	)

func _is_point_in_slice(point) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		polygon.get_polygon() * Transform2D(-rotation, Vector2.ZERO)
	)

func _is_point_in_rotation_area(point) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		rotation_polygon.get_polygon() * Transform2D(-rotation, Vector2.ZERO)
	)
