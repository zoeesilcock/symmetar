class_name SliceWidgets
extends Node2D

# References
@export var pivot_widget : SliceWidget
@export var rotation_widgets : Array[SliceWidget]
@export var scale_widgets : Array[SliceWidget]

func update_widget_positions(polygon : Polygon2D) -> void:
	# Calculate the extents of the shape.
	var rect : Rect2 = Rect2()
	for vector : Vector2 in polygon.polygon:
		rect = rect.expand(vector)

	pivot_widget.position = Vector2.ZERO

	rotation_widgets[0].position = rect.position
	rotation_widgets[1].position = rect.position + Vector2(rect.size.x, 0)
	rotation_widgets[2].position = rect.position + Vector2(0, rect.size.y)
	rotation_widgets[3].position = rect.end

	scale_widgets[0].position = rect.position + Vector2(0, rect.size.y / 2)
	scale_widgets[1].position = rect.position + Vector2(rect.size.x / 2, 0)
	scale_widgets[2].position = rect.position + Vector2(rect.size.x, rect.size.y / 2)
	scale_widgets[3].position = rect.position + Vector2(rect.size.x / 2, rect.size.y)
