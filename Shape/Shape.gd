class_name Shape
extends Node2D

# References
@export var polygon : Polygon2D

# Settings
@export var allow_drag : bool
@export var highlight_brighten : float
@export var slice_index : int

# Signals
signal position_changed

# Internal
var is_dragging
var drag_offset
var view_to_world
var original_color
var highlighted_color

func _ready():
	view_to_world = get_canvas_transform().affine_inverse()
	original_color = polygon.color
	highlighted_color = polygon.color
	highlighted_color.v += highlight_brighten

func _input(event):
	if allow_drag:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var world_position = view_to_world * event.position
			if _is_point_in_shape(world_position - position):
				if not is_dragging and event.pressed:
					drag_offset = world_position - position
					_start_dragging()

			if is_dragging and not event.pressed:
				_end_dragging()

		if is_dragging && event is InputEventMouseMotion:
			_update_dragging(event)

func _start_dragging():
	is_dragging = true
	polygon.color = highlighted_color

func _update_dragging(event):
	position = view_to_world * (event.position - drag_offset)
	position_changed.emit(slice_index)

func _end_dragging():
	is_dragging = false
	polygon.color = original_color

func _is_point_in_shape(point):
	return Geometry2D.is_point_in_polygon(
		point,
		polygon.get_polygon() * Transform2D(-rotation, Vector2.ZERO)
	)
