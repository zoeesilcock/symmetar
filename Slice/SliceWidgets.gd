class_name SliceWidgets
extends Node2D

# References
@export var pivot_widget : SliceWidget
@export var rotation_widgets : Array[SliceWidget]
@export var scale_widgets : Array[SliceWidget]

func _ready() -> void:
	hide_widgets()

func update_widget_positions(rect : Rect2) -> void:
	pivot_widget.position = Vector2.ZERO

	for rotation_widget : SliceWidget in rotation_widgets:
		rotation_widget.update_position(rect)

	for scale_widget : SliceWidget in scale_widgets:
		scale_widget.update_position(rect)

func show_widgets() -> void:
	visible = true
	_set_process_input(true)

func hide_widgets() -> void:
	visible = false
	_set_process_input(false)

func _set_process_input(enable : bool) -> void:
	pivot_widget.set_process_unhandled_input(enable)

	for rotation_widget : SliceWidget in rotation_widgets:
		rotation_widget.set_process_unhandled_input(enable)

	for scale_widget : SliceWidget in scale_widgets:
		scale_widget.set_process_unhandled_input(enable)
