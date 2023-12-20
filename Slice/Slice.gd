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
@export var slice_pivot : Vector2:
	get:
		return polygon.position
	set(value):
		polygon.position = value
		_update_widget_positions()
@export var slice_scale : Vector2:
	get:
		return polygon.scale
	set(value):
		polygon.scale = value
		_update_widget_positions()

# Signals
signal selected(index : int)
signal position_changed(index : int)
signal dragging_ended(index : int)
signal rotation_changed(index : int)
signal rotating_ended(index : int)
signal pivot_changed(index : int)
signal pivot_ended(index : int)
signal scaling_changed(index : int)
signal scaling_ended(index : int)

# Internal
var is_selected : bool

var is_dragging : bool
var drag_offset : Vector2

var is_pivoting	: bool
var pivot_start : Vector2

var is_rotating : bool
var initial_theta : float
var initial_rotation : float

var is_scaling : bool
var scaling_direction : Vector2
var scaling_start_position : Vector2
var initial_scale : Vector2
var initial_posisition : Vector2
var initial_size : Vector2

var view_to_world : Transform2D
var original_color : Color
var highlighted_color : Color
var viewport : Viewport

func init(p_slice_position : Vector2, p_slice_rotation : float, p_slice_pivot : Vector2, p_index : int, p_element_index : int, p_color : Color) -> void:
	name = "Slice" + str(p_index)
	position = p_slice_position
	rotation = p_slice_rotation
	slice_pivot = p_slice_pivot
	set_color(p_color)

	slice_index = p_index
	element_index = p_element_index
	debug_slice_index.text = str(slice_index)

func _ready() -> void:
	view_to_world = get_canvas_transform().affine_inverse()
	viewport = get_viewport()

	ui_state.selection_changed.connect(_on_selection_changed)
	_connect_widget_signals()
	_update_widget_positions()

func _update_widget_positions() -> void:
	slice_widgets.update_widget_positions(_get_rect())

func _connect_widget_signals() -> void:
	slice_widgets.pivot_widget.drag_started.connect(_pivot_started)
	slice_widgets.pivot_widget.drag_updated.connect(_pivot_updated)
	slice_widgets.pivot_widget.drag_ended.connect(_pivot_ended)

	for rotation_widget : SliceWidget in slice_widgets.rotation_widgets:
		rotation_widget.drag_started.connect(_rotation_started)
		rotation_widget.drag_updated.connect(_rotation_updated)
		rotation_widget.drag_ended.connect(_rotation_ended)

	for scale_widget : SliceWidget in slice_widgets.scale_widgets:
		scale_widget.drag_started.connect(Callable(_scaling_started).bind(scale_widget.direction))
		scale_widget.drag_updated.connect(_scaling_updated)
		scale_widget.drag_ended.connect(_scaling_ended)

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
	slice_widgets.show_widgets()

func _hide_selection() -> void:
	slice_widgets.hide_widgets()

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

func _pivot_started(_event : InputEvent, _world_position : Vector2) -> void:
	pivot_start = position + slice_pivot.rotated(rotation)
	is_pivoting = true

func _pivot_updated(_event : InputEvent, world_position : Vector2) -> void:
	slice_pivot = Vector2(pivot_start - world_position).rotated(-rotation)
	position = pivot_start - slice_pivot.rotated(rotation)
	pivot_changed.emit(slice_index)

func _pivot_ended(_event : InputEvent, _world_position : Vector2) -> void:
	is_pivoting = false
	pivot_ended.emit(slice_index)

func _scaling_started(_event : InputEvent, world_position : Vector2, direction : Vector2) -> void:
	scaling_direction = -direction
	scaling_start_position = world_position
	initial_scale = polygon.scale
	initial_size = _get_rect().size
	initial_posisition = polygon.position
	is_scaling = true

func _scaling_updated(_event : InputEvent, world_position : Vector2) -> void:
	var pixel_distance : Vector2 = (scaling_start_position - world_position).rotated(-rotation) * scaling_direction
	var distance : Vector2 = (pixel_distance / initial_size) * initial_scale

	if scaling_direction == Vector2.LEFT or scaling_direction == Vector2.RIGHT:
		polygon.scale = initial_scale + distance * 2
	else:
		polygon.scale = initial_scale + distance
		polygon.position = initial_posisition + pixel_distance / 2 * Vector2.DOWN

	_update_widget_positions()
	scaling_changed.emit(slice_index)

func _scaling_ended(_event : InputEvent, _world_position : Vector2) -> void:
	is_scaling = false
	scaling_ended.emit(slice_index)

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

func get_transformed_polygon() -> PackedVector2Array:
	var transformed_polygon : PackedVector2Array = []
	var translation : Transform2D = Transform2D(rotation, polygon.scale, 0, slice_pivot.rotated(rotation))

	for _vector : Vector2 in polygon.polygon:
		transformed_polygon.append(translation * _vector)

	return transformed_polygon

func _is_point_in_slice(point : Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		get_transformed_polygon()
	)

# Calculate the extents of the shape.
func _get_rect() -> Rect2:
	var rect : Rect2 = Rect2()
	for vector : Vector2 in polygon.polygon:
		rect = rect.expand(vector)

	return polygon.transform * rect
