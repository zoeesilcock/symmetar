class_name Element
extends Node2D

# References
@export var ui_state : UIState
@export var slice_scene : PackedScene
@export var slices_node : Node2D

# Settings
@export var state : ElementState

# Signals
signal state_changed

# Internal
var slices : Array[Slice]
var is_selected : bool
var theta_increment : float:
	get:
		return deg_to_rad(360.0 / state.slice_count)

func init(p_state : ElementState) -> void:
	state = p_state

	state.slice_count_changed.connect(_on_slice_count_state_changed)
	state.slice_shape_changed.connect(_on_slice_shape_state_changed)
	state.slice_rotation_changed.connect(_on_slice_rotation_state_changed)
	state.slice_position_changed.connect(_on_slice_position_state_changed)
	state.slice_pivot_changed.connect(_on_slice_pivot_state_changed)
	state.slice_color_changed.connect(_on_slice_color_state_changed)
	state.slice_outline_width_changed.connect(_on_slice_outline_width_state_changed)
	state.slice_outline_color_changed.connect(_on_slice_outline_color_state_changed)

	_instantiate_slices()
	_update_slice_positions()
	_update_slice_rotations()

func set_index(index : int) -> void:
	state.index = index

	for slice : Slice in slices:
		slice.element_index = index

func get_slice(index : int) -> Slice:
	return slices[index]

func _on_slice_count_state_changed() -> void:
	var current_length : int = len(slices)
	var slice_count_increased : bool = state.slice_count > current_length

	if slice_count_increased:
		var increase : int = state.slice_count - current_length
		slices.resize(state.slice_count)
		for index : int in range(current_length, current_length + increase):
			_instantiate_slice(index)
	else:
		var decrease : int = current_length - state.slice_count
		for index : int in range(current_length - decrease, current_length):
			_remove_slice(index)
		slices.resize(state.slice_count)

	_update_slice_positions()
	_update_slice_rotations()

func _on_slice_shape_state_changed() -> void:
	for slice : Slice in slices:
		slice.set_shape(state.slice_shape)

func _on_slice_rotation_state_changed() -> void:
	slices[0].rotation = state.slice_rotation
	_update_slice_rotations()

func _on_slice_position_state_changed() -> void:
	slices[0].position = state.slice_position
	_update_slice_positions()

func _on_slice_pivot_state_changed() -> void:
	slices[0].slice_pivot = state.slice_pivot
	_update_slice_positions()

func _on_slice_color_state_changed() -> void:
	for slice : Slice in slices:
		slice.set_color(state.slice_color)

func _on_slice_outline_width_state_changed() -> void:
	for slice : Slice in slices:
		slice.set_outline_width(state.slice_outline_width)

func _on_slice_outline_color_state_changed() -> void:
	for slice : Slice in slices:
		slice.set_outline_color(state.slice_outline_color)

func _on_slice_position_changed(slice_index : int) -> void:
	_update_slice_positions(slice_index)

func _on_slice_rotation_changed(slice_index : int) -> void:
	_update_slice_rotations(slice_index)

func _on_slice_rotation_ended(slice_index : int) -> void:
	state_changed.emit(slice_index)

func _on_slice_pivot_changed(slice_index : int) -> void:
	_update_slice_positions(slice_index)

func _on_slice_pivot_ended(slice_index : int) -> void:
	state_changed.emit(slice_index)

func _on_slice_scale_changed(slice_index : int) -> void:
	_update_slice_scales(slice_index)

func _on_slice_scale_ended(slice_index : int) -> void:
	state_changed.emit(slice_index)

func _on_slice_dragging_ended(slice_index : int) -> void:
	state_changed.emit(slice_index)

func _on_slice_selected(slice_index : int) -> void:
	ui_state.set_selection(state.index, slice_index)

func _instantiate_slices() -> void:
	slices = []
	slices.resize(state.slice_count)

	for index : int in state.slice_count:
		_instantiate_slice(index)

func _instantiate_slice(index : int) -> void:
	slices[index] = slice_scene.instantiate()
	slices_node.add_child(slices[index])

	slices[index].init(
		state.index,
		index,
		state.slice_position,
		state.slice_rotation,
		state.slice_pivot,
		state.slice_shape,
		state.slice_color,
		state.slice_outline_width,
		state.slice_outline_color,
	)

	slices[index].position_changed.connect(_on_slice_position_changed)
	slices[index].rotation_changed.connect(_on_slice_rotation_changed)
	slices[index].rotating_ended.connect(_on_slice_rotation_ended)
	slices[index].pivot_changed.connect(_on_slice_pivot_changed)
	slices[index].pivot_ended.connect(_on_slice_pivot_ended)
	slices[index].scaling_changed.connect(_on_slice_scale_changed)
	slices[index].scaling_ended.connect(_on_slice_scale_ended)
	slices[index].dragging_ended.connect(_on_slice_dragging_ended)
	slices[index].selected.connect(_on_slice_selected)

func _remove_slice(index : int) -> void:
	slices[index].position_changed.disconnect(_on_slice_position_changed)
	slices[index].rotation_changed.disconnect(_on_slice_rotation_changed)
	slices[index].rotating_ended.disconnect(_on_slice_rotation_ended)
	slices[index].pivot_changed.disconnect(_on_slice_pivot_changed)
	slices[index].pivot_ended.disconnect(_on_slice_pivot_ended)
	slices[index].scaling_changed.disconnect(_on_slice_scale_changed)
	slices[index].scaling_ended.disconnect(_on_slice_scale_ended)
	slices[index].dragging_ended.disconnect(_on_slice_dragging_ended)
	slices[index].selected.disconnect(_on_slice_selected)

	slices_node.remove_child(slices[index])
	slices[index].queue_free()

func _update_slice_positions(slice_index : int = 0) -> void:
	var slice : Slice = slices[slice_index]
	var origin_radius : float = sqrt(pow(slice.position.x, 2) + pow(slice.position.y, 2))
	var origin_theta : float = atan2(slice.position.y, slice.position.x)

	for index : int in state.slice_count:
		var theta : float = (slice_index - index) * theta_increment
		var slice_position : Vector2 = (origin_radius * Vector2.from_angle(theta + origin_theta))

		if index != slice_index:
			slices[index].position = slice_position - position
			slices[index].slice_pivot = slice.slice_pivot

		slices[index].update_outline_position()

	# Update the state
	state.slice_rotation = slices[0].rotation
	state.slice_position = slices[0].position
	state.slice_pivot = slices[0].slice_pivot

func _update_slice_rotations(slice_index : int = 0) -> void:
	var slice_rotation : float = slices[slice_index].rotation

	for index : int in state.slice_count:
		if index != slice_index:
			var theta : float = (slice_index - index) * theta_increment
			slices[index].rotation = slice_rotation + theta

	# Update the state
	state.slice_rotation = slices[0].rotation

func _update_slice_scales(slice_index : int = 0) -> void:
	var slice : Slice = slices[slice_index]

	for index : int in state.slice_count:
		if index != slice_index:
			slices[index].slice_scale = slice.slice_scale
			slices[index].slice_pivot = slice.slice_pivot

		slices[index].update_outline_scale()

	# Update the state
	state.slice_scale = slice.slice_scale
