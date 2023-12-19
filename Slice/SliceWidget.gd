class_name SliceWidget
extends Node2D

# References
@export var ui_state : UIState
@export var shape : Polygon2D
@export var selection : Polygon2D
@export var relative_position : Vector2
@export var direction : Vector2

# Signals
signal drag_started(event : InputEvent, world_position : Vector2)
signal drag_updated(event : InputEvent, world_position : Vector2)
signal drag_ended(event : InputEvent, world_position : Vector2)

# Internal
var view_to_world : Transform2D
var viewport : Viewport
var is_dragging : bool

func _ready() -> void:
	view_to_world = get_canvas_transform().affine_inverse()
	viewport = get_viewport()

func update_position(rect : Rect2) -> void:
	position = rect.position + relative_position * rect.size

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var world_position : Vector2 = view_to_world * event.position
		var cursor_in_selection : bool = _is_in_selection(world_position - global_position)

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_dragging and cursor_in_selection:
				viewport.set_input_as_handled()
				_start_dragging(event, world_position)
			elif not event.pressed and is_dragging:
				_end_dragging(event, world_position)

		if event is InputEventMouseMotion:
			if is_dragging:
				viewport.set_input_as_handled()
				_update_dragging(event, world_position)

			if cursor_in_selection or is_dragging:
				selection.visible = true
			else:
				selection.visible = false

func _is_in_selection(point : Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, selection.get_polygon())

func _start_dragging(event : InputEvent, world_position : Vector2) -> void:
	is_dragging = true
	drag_started.emit(event, world_position)

func _update_dragging(event : InputEvent, world_position : Vector2) -> void:
	drag_updated.emit(event, world_position)

func _end_dragging(event : InputEvent, world_position : Vector2) -> void:
	is_dragging = false
	drag_ended.emit(event, world_position)
