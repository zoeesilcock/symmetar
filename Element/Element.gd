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
var slices
var is_selected : bool
var theta_increment : float:
	get:
		return deg_to_rad(360.0 / state.slice_count)

func init(p_state : ElementState):
	state = p_state

	state.slice_count_changed.connect(_on_slice_count_changed)
	state.slice_color_changed.connect(_on_slice_color_changed)

	_instantiate_slices()
	_update_slice_positions()
	_update_slice_rotations()

func _on_slice_position_changed(slice_index : int):
	_update_slice_positions(slice_index)

func _on_slice_rotation_changed(slice_index : int):
	_update_slice_rotations(slice_index)

func _on_slice_dragging_ended(slice_index : int):
	state_changed.emit(slice_index)

func _on_slice_selected(slice_index : int):
	ui_state.set_selection(state.index, slice_index)

func _on_slice_count_changed():
	var current_length = len(slices)
	var slice_count_increased = state.slice_count > current_length

	if slice_count_increased:
		var increase = state.slice_count - current_length
		slices.resize(state.slice_count)
		for i in range(current_length, current_length + increase):
			_instantiate_slice(i)
	else:
		var decrease = current_length - state.slice_count
		for i in range(current_length - decrease, current_length):
			_remove_slice(i)
		slices.resize(state.slice_count)

	_update_slice_positions()
	_update_slice_rotations()

func _on_slice_color_changed():
	for slice in slices:
		slice.set_color(state.slice_color)

func _instantiate_slices():
	slices = []
	slices.resize(state.slice_count)

	for i in state.slice_count:
		_instantiate_slice(i)

func _instantiate_slice(index : int):
	slices[index] = slice_scene.instantiate()
	slices_node.add_child(slices[index])

	slices[index].init(
		state.slice_position,
		state.slice_rotation,
		index,
		state.index,
		state.slice_color
	)

	slices[index].position_changed.connect(_on_slice_position_changed)
	slices[index].rotation_changed.connect(_on_slice_rotation_changed)
	slices[index].dragging_ended.connect(_on_slice_dragging_ended)
	slices[index].selected.connect(_on_slice_selected)

func _remove_slice(index : int):
	slices[index].position_changed.disconnect(_on_slice_position_changed)
	slices[index].rotation_changed.disconnect(_on_slice_rotation_changed)
	slices[index].dragging_ended.disconnect(_on_slice_dragging_ended)
	slices[index].selected.disconnect(_on_slice_selected)
	slices_node.remove_child(slices[index])
	slices[index].queue_free()

func _update_slice_positions(slice_index : int = 0):
	var slice = slices[slice_index]
	var origin_radius = sqrt(pow(slice.position.x, 2) + pow(slice.position.y, 2))
	var origin_theta = atan2(slice.position.y, slice.position.x)

	for i in state.slice_count:
		var theta = (slice_index - i) * theta_increment
		var slice_position = (origin_radius * Vector2.from_angle(theta + origin_theta))

		if (i != slice_index):
			slices[i].position = slice_position - position

	# Update the state
	state.radius = origin_radius
	state.slice_rotation = slices[0].rotation
	state.slice_position = slices[0].position

func _update_slice_rotations(slice_index : int = 0):
	var slice_rotation = slices[slice_index].rotation

	for i in state.slice_count:
		if (i != slice_index):
			var theta = (slice_index - i) * theta_increment
			slices[i].rotation = slice_rotation + theta

	# Update the state
	state.slice_rotation = slices[0].rotation
