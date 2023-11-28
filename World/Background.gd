extends Node2D

@export var ui_state : UIState

func _unhandled_input(event : InputEvent) -> void:
	if (event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and
		not event.pressed
	):
		ui_state.set_selection(-1, -1)
