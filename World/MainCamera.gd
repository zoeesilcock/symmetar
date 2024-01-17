class_name MainCamera
extends Camera2D

# Internal
var is_panning : bool
var panning_start_camera_position : Vector2
var panning_start_mouse_position : Vector2

func reset_to_center() -> void:
	position = Vector2.ZERO

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_start_panning(event)
			else:
				_end_panning()

	if event is InputEventMouseMotion and is_panning:
		_update_panning(event)

func _get_world_position(event_position : Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * event_position

func _start_panning(event : InputEvent) -> void:
	is_panning = true
	panning_start_camera_position = position
	panning_start_mouse_position = _get_world_position(event.position - position)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _update_panning(event : InputEvent) -> void:
	var world_position : Vector2 = _get_world_position(event.position - position)
	position = panning_start_camera_position - (world_position - panning_start_mouse_position)

func _end_panning() -> void:
	is_panning = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
