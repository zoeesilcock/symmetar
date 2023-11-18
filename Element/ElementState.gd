class_name ElementState
extends Resource

# Data
@export var slice_count : int:
	set(value):
		var value_changed = value != slice_count
		slice_count = value
		if value_changed:
			slice_count_changed.emit()

@export var radius : float
@export var slice_rotation : float
@export var slice_position : Vector2

# Signals
signal slice_count_changed
