class_name MainCamera
extends Camera2D

# Settings
@export var scroll_wheel_zoom_amount: float
@export var min_zoom: float
@export var max_zoom: float

# References
@export var document: Document

# Internal
var is_panning: bool
var panning_start_camera_position: Vector2
var panning_start_mouse_position: Vector2

func _ready() -> void:
	document.document_state_replaced.connect(_on_document_state_replaced)

func _on_document_state_replaced() -> void:
	document.state.zoom_changed.connect(_on_zoom_state_changed)
	document.state.pan_position_changed.connect(_on_pan_position_state_changed)

func _on_zoom_state_changed() -> void:
	zoom = Vector2(document.state.zoom, document.state.zoom)

func _on_pan_position_state_changed() -> void:
	position = document.state.pan_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_start_panning(event)
			else:
				_end_panning()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(scroll_wheel_zoom_amount)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(-scroll_wheel_zoom_amount)

	if event is InputEventMouseMotion and is_panning:
		_update_panning(event)

func _get_world_position(event_position: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * event_position

func _start_panning(event: InputEvent) -> void:
	is_panning = true
	panning_start_camera_position = position
	panning_start_mouse_position = _get_world_position(event.position) - position
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _update_panning(event: InputEvent) -> void:
	var world_position: Vector2 = _get_world_position(event.position) - position
	document.state.pan_position = panning_start_camera_position - (world_position - panning_start_mouse_position)

func _end_panning() -> void:
	is_panning = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _change_zoom(amount: float) -> void:
	var new_zoom: float = clamp(zoom.x + amount, min_zoom, max_zoom)
	document.state.zoom = new_zoom
