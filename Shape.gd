class_name Shape
extends Node2D

# References
@export var polygon : Polygon2D

# Settings
@export var allow_drag : bool

# Signals
signal position_changed

# Internal
var is_dragging
var view_to_world

func _ready():
	view_to_world = get_canvas_transform().affine_inverse()

func _input(event):
	if allow_drag:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var world_position = view_to_world * event.position
			if _is_point_in_shape(world_position - position):
				if not is_dragging and event.pressed:
					is_dragging = true

			if is_dragging and not event.pressed:
				is_dragging = false

		if is_dragging && event is InputEventMouseMotion:
			position = view_to_world * event.position
			position_changed.emit()

func _is_point_in_shape(point):
	return Geometry2D.is_point_in_polygon(point, polygon.get_polygon())
