class_name Main
extends Node2D

# References
@export var ui_state: UIState

func _ready() -> void:
	ui_state.main_window_scale = _calculate_main_scale()

	_set_main_window_size()
	_set_main_window_scale()
	_set_main_window_position()

func _set_main_window_size() -> void:
	var default_window_size: Vector2 = Vector2(
		ProjectSettings.get("display/window/size/viewport_width"),
		ProjectSettings.get("display/window/size/viewport_height")
	)

	DisplayServer.window_set_min_size(default_window_size * ui_state.main_window_scale)
	DisplayServer.window_set_size(default_window_size * ui_state.main_window_scale)

func _set_main_window_scale() -> void:
	get_tree().root.content_scale_factor = ui_state.main_window_scale

func _set_main_window_position() -> void:
	var screen_center: Vector2 = DisplayServer.screen_get_size() / 2
	var window_size: Vector2 = DisplayServer.window_get_size()

	DisplayServer.window_set_position(screen_center - window_size / 2)

func _calculate_main_scale() -> float:
	var main_scale: float = 1.0

	if OS.get_name() == "macOS":
		main_scale = DisplayServer.screen_get_max_scale()
	else:
		if DisplayServer.screen_get_dpi() >= 192:
			main_scale = 2.0

	return main_scale
