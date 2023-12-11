class_name SliceWidgets
extends Node2D

# References
@export var pivot_widget : SliceWidget
@export var rotation_widgets : Array[SliceWidget]
@export var scale_widgets : Array[SliceWidget]

func update_widget_positions(rect : Rect2) -> void:
	pivot_widget.position = Vector2.ZERO

	for rotation_widget in rotation_widgets:
		rotation_widget.update_position(rect)

	for scale_widget in scale_widgets:
		scale_widget.update_position(rect)
