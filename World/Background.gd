class_name Background
extends Node2D

# References
@export var ui_state : UIState
@export var document : Document

func _ready() -> void:
	document.document_state_replaced.connect(_on_document_state_replaced)

func _on_document_state_replaced() -> void:
	document.state.background_color_changed.connect(_on_background_color_changed)

func _on_background_color_changed() -> void:
	queue_redraw()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == MOUSE_BUTTON_LEFT and \
		not ui_state.slice_color_picker_visible and \
		not ui_state.slice_outline_color_picker_visible and \
		event.pressed:
			ui_state.set_selection(-1, -1)

func _draw() -> void:
	var rect : Rect2 = get_viewport().get_visible_rect()
	rect.position = Vector2(-rect.size.x / 2, -rect.size.y / 2)
	draw_rect(rect, document.state.background_color)
