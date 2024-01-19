class_name Background
extends Node2D

# References
@export var ui_state : UIState
@export var document : Document
@export var main_camera : MainCamera

func _ready() -> void:
	document.document_state_replaced.connect(_on_document_state_replaced)

func _on_document_state_replaced() -> void:
	document.state.background_color_changed.connect(_on_background_color_changed)
	document.state.zoom_changed.connect(_on_camera_zoom_changed)

func _on_background_color_changed() -> void:
	queue_redraw()

func _on_camera_zoom_changed() -> void:
	queue_redraw()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == MOUSE_BUTTON_LEFT and \
		not ui_state.slice_color_picker_visible and \
		not ui_state.slice_outline_color_picker_visible and \
		event.pressed:
			ui_state.set_selection(-1, -1)

func _draw() -> void:
	var scaled_viewport_size : Vector2 = get_viewport_rect().size / main_camera.zoom
	var camera_rect : Rect2 = Rect2(-scaled_viewport_size / 2, scaled_viewport_size)
	draw_rect(camera_rect, document.state.background_color)
