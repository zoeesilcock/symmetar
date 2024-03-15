class_name Slice
extends Node2D

# References
@export var ui_state: UIState
@export var shapes: Shapes
@export var outline: SliceOutline
@export var slice_widgets: SliceWidgets
@export var debug_slice_index: Label

# Settings
@export var highlight_brighten: float
@export var element_index: int
@export var slice_index: int
@export var slice_pivot: Vector2:
	get:
		return polygon.position
	set(value):
		polygon.position = value
		_update_widget_positions()
@export var slice_scale: Vector2:
	get:
		return polygon.scale
	set(value):
		polygon.scale = value
		_update_widget_positions()

# Signals
signal selected(index: int, shift_held: bool)
signal position_changed(index: int)
signal dragging_ended(index: int)
signal rotation_changed(index: int)
signal rotating_ended(index: int)
signal pivot_changed(index: int)
signal pivot_ended(index: int)
signal scaling_changed(index: int)
signal scaling_ended(index: int)

# Internal
var polygon: Polygon2D # TODO: Rename to shape?
var is_selected: bool
var was_just_selected: bool
var is_highlighted: bool
var cursor_is_in_slice: bool
var shift_is_held: bool

var this_slice_is_busy: bool:
	get:
		return (
			is_dragging or
			is_rotating or
			is_pivoting or
			is_scaling
		)

var is_dragging: bool
var dragging_start_theta: float
var dragging_start_position: Vector2
var drag_offset: Vector2
var dragging_changed_position: bool:
	get:
		return (
			is_dragging and
			position != dragging_start_position
		)

var is_pivoting: bool
var pivot_start: Vector2

var is_rotating: bool
var initial_theta: float
var initial_rotation: float

var is_scaling: bool
var scaling_direction: Vector2
var scaling_start_position: Vector2
var initial_scale: Vector2
var initial_posisition: Vector2
var initial_size: Vector2
var last_scaling_world_position: Vector2

var original_color: Color
var highlighted_color: Color
var viewport: Viewport

func init(
		p_element_index: int,
		p_slice_index: int,
		p_slice_position: Vector2,
		p_slice_rotation: float,
		p_slice_pivot: Vector2,
		p_slice_scale: Vector2,
		p_shape_index: Shapes.ShapeIndex,
		p_slice_color: Color,
		p_slice_outline_width: float,
		p_slice_outline_color: Color) -> void:
	name = "Slice" + str(p_slice_index)
	set_shape(p_shape_index)
	position = p_slice_position
	rotation = p_slice_rotation
	slice_pivot = p_slice_pivot
	slice_scale = p_slice_scale
	set_color(p_slice_color)
	set_outline_width(p_slice_outline_width)
	set_outline_color(p_slice_outline_color)

	slice_index = p_slice_index
	element_index = p_element_index
	debug_slice_index.text = str(slice_index)

	_connect_widget_signals()
	_update_widget_positions()

	update_outline_position()
	update_outline_scale()

func _ready() -> void:
	viewport = get_viewport()
	ui_state.selection_changed.connect(_on_selection_changed)

func _update_widget_positions() -> void:
	slice_widgets.update_widget_positions(_get_rect())

func _connect_widget_signals() -> void:
	slice_widgets.pivot_widget.drag_started.connect(_pivot_started)
	slice_widgets.pivot_widget.drag_updated.connect(_pivot_updated)
	slice_widgets.pivot_widget.drag_ended.connect(_pivot_ended)

	for rotation_widget: SliceWidget in slice_widgets.rotation_widgets:
		rotation_widget.drag_started.connect(_rotation_started)
		rotation_widget.drag_updated.connect(_rotation_updated)
		rotation_widget.drag_ended.connect(_rotation_ended)

	for scale_widget: SliceWidget in slice_widgets.scale_widgets:
		scale_widget.drag_started.connect(Callable(_scaling_started).bind(scale_widget.direction))
		scale_widget.drag_updated.connect(_scaling_updated)
		scale_widget.drag_ended.connect(_scaling_ended)

func set_shape(shape_index: Shapes.ShapeIndex) -> void:
	if polygon != null:
		remove_child(polygon)

	var shape_info: ShapeInfo = shapes.get_shape_info(shape_index)
	polygon = shape_info.scene.instantiate()
	polygon.color = original_color

	add_child(polygon)
	move_child(polygon, 0)

	outline.init(polygon)
	_update_widget_positions()

func set_color(color: Color) -> void:
	original_color = color
	polygon.color = color
	highlighted_color = color
	highlighted_color.v += highlight_brighten

func set_outline_width(width: float) -> void:
	outline.set_width(width)

func set_outline_color(color: Color) -> void:
	outline.set_color(color)

func update_outline_position() -> void:
	outline.update_position()

func update_outline_scale() -> void:
	outline.update_scale()

func set_slice_scale(value: Vector2) -> void:
	slice_scale = value
	scaling_changed.emit(slice_index)
	scaling_ended.emit(slice_index)

func set_slice_rotation(value: float) -> void:
	rotation = value
	rotation_changed.emit(slice_index)
	rotating_ended.emit(slice_index)

func get_radius() -> float:
	return position.distance_to(Vector2.ZERO)

func set_radius(radius: float) -> void:
	var theta: float = get_theta()
	position = radius * Vector2.from_angle(theta)
	position_changed.emit(slice_index)

func get_theta() -> float:
	return wrapf(atan2(position.y, position.x), 0, PI * 2)

func set_theta(theta: float) -> void:
	var radius: float = get_radius()
	position = radius * Vector2.from_angle(theta)
	position_changed.emit(slice_index)

func _get_world_position(event_position: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * event_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_handle_mouse_input(event)

	if event is InputEventKey and event.keycode == KEY_SHIFT:
		_handle_shift_key(event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_handle_low_priority_mouse_input(event)

func _handle_mouse_input(event: InputEventMouse) -> void:
	var world_position: Vector2 = _get_world_position(event.position)
	cursor_is_in_slice = _is_point_in_slice(world_position - position)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event, world_position)

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event, world_position)

func _handle_mouse_button(event: InputEventMouseButton, world_position: Vector2) -> void:
	if is_selected and event.pressed and not ui_state.any_slice_is_busy and cursor_is_in_slice:
		viewport.set_input_as_handled()
		_start_dragging(world_position)
	elif not event.pressed and is_dragging:
		if dragging_changed_position or was_just_selected:
			was_just_selected = false
			viewport.set_input_as_handled()
		_end_dragging()
	elif not event.pressed and is_highlighted and not is_selected and cursor_is_in_slice and not ui_state.any_slice_is_busy:
		viewport.set_input_as_handled()
		_trigger_selected()

func _handle_mouse_motion(event: InputEventMouseMotion, world_position: Vector2) -> void:
	if is_selected and is_dragging:
		viewport.set_input_as_handled()
		_update_dragging(event, world_position)

		if not slice_widgets.visible:
			_show_selection()

func _handle_shift_key(event: InputEventKey) -> void:
	if not shift_is_held and event.pressed:
		shift_is_held = true

		if is_scaling:
			_repeat_last_scaling()
	elif shift_is_held and not event.pressed:
		shift_is_held = false

		if is_scaling:
			_repeat_last_scaling()

func _handle_low_priority_mouse_input(event: InputEventMouse) -> void:
	var world_position: Vector2 = _get_world_position(event.position)
	cursor_is_in_slice = _is_point_in_slice(world_position - position)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_low_priority_mouse_button(event, world_position)

	if event is InputEventMouseMotion:
		_handle_low_priority_mouse_motion(event)

func _handle_low_priority_mouse_button(event: InputEventMouseButton, world_position: Vector2) -> void:
	if not ui_state.any_slice_is_busy and cursor_is_in_slice:
		if event.pressed:
			viewport.set_input_as_handled()
			_start_dragging(world_position)
		elif not shift_is_held:
			if is_highlighted and not is_selected:
				viewport.set_input_as_handled()
				_trigger_selected()
			elif not is_selected:
				viewport.set_input_as_handled()
				_trigger_selected()

func _handle_low_priority_mouse_motion(_event: InputEventMouseMotion) -> void:
	if is_highlighted and not cursor_is_in_slice:
		_hide_highlight()
	elif not is_highlighted and cursor_is_in_slice:
		_show_highlight()

func _show_selection() -> void:
	slice_widgets.show_widgets()
	polygon.z_index = 1
	outline.z_index = 1

func _hide_selection() -> void:
	slice_widgets.hide_widgets()
	polygon.z_index = 0
	outline.z_index = 0

func _show_highlight() -> void:
	if this_slice_is_busy or not ui_state.any_slice_is_busy and not ui_state.any_slice_is_highlighted:
		polygon.color = highlighted_color
		is_highlighted = true
		ui_state.any_slice_is_highlighted = true
		viewport.set_input_as_handled()
		polygon.z_index = 1
		outline.z_index = 1

func _hide_highlight() -> void:
	if not this_slice_is_busy and not cursor_is_in_slice:
		polygon.color = original_color
		is_highlighted = false
		ui_state.any_slice_is_highlighted = false
		polygon.z_index = 0
		outline.z_index = 0

func _start_dragging(world_position: Vector2) -> void:
	_trigger_selected()

	dragging_start_theta = atan2(position.y, position.x)
	dragging_start_position = position

	drag_offset = world_position - position
	ui_state.any_slice_is_dragging = true
	is_dragging = true
	_show_highlight()

func _update_dragging(event: InputEvent, world_position: Vector2) -> void:
	if shift_is_held:
		var input_radius: float = sqrt(pow(world_position.x, 2) + pow(world_position.y, 2))
		position = input_radius * Vector2.from_angle(dragging_start_theta)
	else:
		position = _get_world_position(event.position) - drag_offset

	position_changed.emit(slice_index)

func _end_dragging() -> void:
	ui_state.any_slice_is_dragging = false
	is_dragging = false
	_hide_highlight()

	if dragging_changed_position:
		dragging_ended.emit(slice_index)

func _rotation_started(_event: InputEvent, world_position: Vector2) -> void:
	var relative_mouse_position: Vector2 = world_position - position
	initial_rotation = rotation
	initial_theta = atan2(relative_mouse_position.y, relative_mouse_position.x)
	ui_state.any_slice_is_rotating = true
	is_rotating = true
	_show_highlight()

func _rotation_updated(_event: InputEvent, world_position: Vector2) -> void:
	var relative_mouse_position: Vector2 = world_position - position
	var theta: float = atan2(relative_mouse_position.y, relative_mouse_position.x)

	rotation = wrapf((initial_rotation - initial_theta) + theta, 0, PI * 2)
	rotation_changed.emit(slice_index)

func _rotation_ended(_event: InputEvent, _world_position: Vector2) -> void:
	ui_state.any_slice_is_rotating = false
	is_rotating = false
	_hide_highlight()
	rotating_ended.emit(slice_index)

func _pivot_started(_event: InputEvent, _world_position: Vector2) -> void:
	pivot_start = position + slice_pivot.rotated(rotation)
	ui_state.any_slice_is_pivoting = true
	is_pivoting = true
	_show_highlight()

func _pivot_updated(_event: InputEvent, world_position: Vector2) -> void:
	slice_pivot = Vector2(pivot_start - world_position).rotated(-rotation)
	position = pivot_start - slice_pivot.rotated(rotation)
	pivot_changed.emit(slice_index)

func _pivot_ended(_event: InputEvent, _world_position: Vector2) -> void:
	ui_state.any_slice_is_pivoting = false
	is_pivoting = false
	_hide_highlight()
	pivot_ended.emit(slice_index)

func _scaling_started(_event: InputEvent, world_position: Vector2, direction: Vector2) -> void:
	scaling_direction = -direction
	scaling_start_position = world_position
	initial_scale = polygon.scale
	initial_size = _get_rect().size
	initial_posisition = polygon.position
	last_scaling_world_position = world_position
	ui_state.any_slice_is_scaling = true
	is_scaling = true
	_show_highlight()

func _scaling_updated(_event: InputEvent, world_position: Vector2) -> void:
	var pixel_distance: Vector2 = (scaling_start_position - world_position).rotated(-rotation) * scaling_direction
	var distance: Vector2 = (pixel_distance / initial_size) * initial_scale

	if shift_is_held:
		if scaling_direction == Vector2.LEFT or scaling_direction == Vector2.RIGHT:
			distance.y = distance.x
		else:
			distance.x = distance.y

	polygon.scale = initial_scale + distance * 2
	polygon.position = initial_posisition + pixel_distance / 2 * Vector2.DOWN

	_update_widget_positions()
	scaling_changed.emit(slice_index)
	last_scaling_world_position = world_position

func _repeat_last_scaling() -> void:
	_scaling_updated(null, last_scaling_world_position)

func _scaling_ended(_event: InputEvent, _world_position: Vector2) -> void:
	ui_state.any_slice_is_scaling = false
	is_scaling = false
	_hide_highlight()
	scaling_ended.emit(slice_index)

func _trigger_selected() -> void:
	if !is_selected:
		was_just_selected = true
	else:
		was_just_selected = false

	selected.emit(slice_index, shift_is_held)

func _set_selection(enabled: bool) -> void:
	is_selected = enabled

	if enabled:
		_show_selection()
	else:
		_hide_selection()

func _on_selection_changed() -> void:
	_set_selection(ui_state.is_selected(UISelection.new(element_index, slice_index)))

func _get_transformed_polygon() -> PackedVector2Array:
	var transformed_polygon: PackedVector2Array = []
	var translation: Transform2D = Transform2D(rotation, polygon.scale, 0, slice_pivot.rotated(rotation))

	for point: Vector2 in polygon.polygon:
		transformed_polygon.append(translation * point)

	return transformed_polygon

func _is_point_in_slice(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(
		point,
		_get_transformed_polygon()
	)

# Calculate the extents of the shape.
func _get_rect() -> Rect2:
	var rect: Rect2 = Rect2()
	for vector: Vector2 in polygon.polygon:
		rect = rect.expand(vector)

	return polygon.transform * rect
