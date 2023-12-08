class_name Slice
extends Node2D

# References
@export var ui_state : UIState
@export var polygon : Polygon2D
@export var slice_widgets : SliceWidgets
@export var debug_slice_index : Label

# Settings
@export var highlight_brighten : float
@export var element_index : int
@export var slice_index : int

# Signals
signal selected(index : int)
signal position_changed(index : int)
signal dragging_ended(index : int)
signal rotation_changed(index : int)
signal rotating_ended(index : int)

# Internal
var is_selected : bool

var is_dragging : bool
var drag_offset : Vector2

var is_rotating : bool
var initial_theta : float
var initial_rotation : float

var view_to_world : Transform2D
var original_color : Color
var highlighted_color : Color
var viewport : Viewport

func init(p_slice_position : Vector2, p_slice_rotation : float, p_index : int, p_element_index : int, p_color : Color) -> void:
	name = "Slice" + str(p_index)
	position = p_slice_position
	rotation = p_slice_rotation
	set_color(p_color)

	slice_index = p_index
	element_index = p_element_index
	debug_slice_index.text = str(slice_index)

func _ready() -> void:
	view_to_world = get_canvas_transform().affine_inverse()
	viewport = get_viewport()

	ui_state.selection_changed.connect(_on_selection_changed)
	_connect_widget_signals()
	slice_widgets.update_widget_positions(polygon)

func _connect_widget_signals() -> void:
	for rotation_widget : SliceWidget in slice_widgets.rotation_widgets:
		rotation_widget.drag_started.connect(_rotation_started)
		rotation_widget.drag_updated.connect(_rotation_updated)
		rotation_widget.drag_ended.connect(_rotation_ended)

func set_color(color : Color) -> void:
	original_color = color
	polygon.color = color
	highlighted_color = color
	highlighted_color.v += highlight_brighten

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var world_position : Vector2 = view_to_world * event.position
		var cursor_in_slice : bool = _is_point_in_slice(world_position - position)
		var any_slice_busy : bool = ui_state.any_slice_is_dragging || ui_state.any_slice_is_rotating

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			# Dragging
			if event.pressed and not any_slice_busy and cursor_in_slice:
				viewport.set_input_as_handled()
				_start_dragging(world_position)
			elif not event.pressed and is_dragging:
				viewport.set_input_as_handled()
				_end_dragging()

		if is_selected and event is InputEventMouseMotion:
			if is_dragging:
				viewport.set_input_as_handled()
				_update_dragging(event)

				if not slice_widgets.visible:
					_show_selection()

func _show_selection() -> void:
	slice_widgets.visible = true

func _hide_selection() -> void:
	slice_widgets.visible = false

func _start_dragging(world_position : Vector2) -> void:
	selected.emit(slice_index)

	drag_offset = world_position - position
	ui_state.any_slice_is_dragging = true
	is_dragging = true
	polygon.color = highlighted_color

func _update_dragging(event : InputEvent) -> void:
	position = view_to_world * (event.position - drag_offset)
	position_changed.emit(slice_index)

func _end_dragging() -> void:
	ui_state.any_slice_is_dragging = false
	is_dragging = false
	polygon.color = original_color
	dragging_ended.emit(slice_index)

func _rotation_started(_event : InputEvent, world_position : Vector2) -> void:
	var relative_mouse_position : Vector2 = world_position - position
	initial_rotation = rotation
	initial_theta = atan2(relative_mouse_position.y, relative_mouse_position.x)
	ui_state.any_slice_is_rotating = true
	is_rotating = true
	polygon.color = highlighted_color

func _rotation_updated(_event : InputEvent, world_position : Vector2) -> void:
	var relative_mouse_position : Vector2 = world_position - position
	var theta : float = atan2(relative_mouse_position.y, relative_mouse_position.x)

	rotation = (initial_rotation - initial_theta) + theta
	rotation_changed.emit(slice_index)

func _rotation_ended(_event : InputEvent, _world_position : Vector2) -> void:
	ui_state.any_slice_is_rotating = false
	is_rotating = false
	polygon.color = original_color
	rotating_ended.emit(slice_index)

func _set_selection(enabled : bool) -> void:
	is_selected = enabled

	if enabled:
		_show_selection()
	else:
		_hide_selection()

func _on_selection_changed() -> void:
	_set_selection(
		ui_state.selected_element_index == element_index and
		ui_state.selected_slice_index == slice_index
	)

func _is_point_in_slice(point : Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		polygon.get_polygon() * Transform2D(-rotation, Vector2.ZERO)
	)
