class_name SliceOutline
extends Node2D

# References
@export var polygon : Polygon2D

# Internal
var lines : Array[Line2D]

func _ready() -> void:
	_spawn_lines()

func set_width(width : float) -> void:
	for line : Line2D in lines:
		line.width = width

func set_color(color : Color) -> void:
	for line : Line2D in lines:
		line.default_color = color

func update_position() -> void:
	position = polygon.position

func update_scale() -> void:
	update_position()
	_update_lines()

func _update_lines() -> void:
	var scaled_polygon : PackedVector2Array = _get_scaled_polygon()

	for index : int in scaled_polygon.size():
		var next_index : int = _get_next_index(index)

		lines[index].set_point_position(0, scaled_polygon[index])
		lines[index].set_point_position(1, scaled_polygon[next_index])

func _spawn_lines() -> void:
	var scaled_polygon : PackedVector2Array = _get_scaled_polygon()

	for index : int in scaled_polygon.size():
		var next_index : int = _get_next_index(index)
		var line : Line2D = Line2D.new()

		line.add_point(scaled_polygon[index])
		line.add_point(scaled_polygon[next_index])
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND

		lines.push_back(line)
		add_child(line)

func _get_next_index(index : int) -> int:
	var next_index : int = index + 1

	if next_index >= polygon.polygon.size():
		next_index = 0

	return next_index

func _get_scaled_polygon() -> PackedVector2Array:
	var scaled_polygon : PackedVector2Array = []
	var translation : Transform2D = Transform2D(rotation, polygon.scale, 0, Vector2.ZERO)

	for point : Vector2 in polygon.polygon:
		scaled_polygon.append(translation * point)

	return scaled_polygon
