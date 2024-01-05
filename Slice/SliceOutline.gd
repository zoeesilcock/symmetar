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

func update_scale() -> void:
	position = polygon.position
	scale = polygon.scale

func _spawn_lines() -> void:
	for index : int in polygon.polygon.size():
		var next_index : int = index + 1
		if next_index >= polygon.polygon.size():
			next_index = 0

		var line : Line2D = Line2D.new()
		line.add_point(polygon.polygon[index])
		line.add_point(polygon.polygon[next_index])
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND

		lines.push_back(line)
		add_child(line)
