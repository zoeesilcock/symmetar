class_name Element
extends Node2D

# References
@export var ui_state : UIState
@export var shape_scene : PackedScene
@export var slices_node : Node2D

# Settings
@export var element_index : int
@export var state : ElementState

# Internal
var slices
var is_selected

func init(element_index : int, state : ElementState):
	self.element_index = element_index
	self.state = state

	state.slice_count_changed.connect(_on_slice_count_changed)

	_instantiate_slices()
	_update_slices()

func _on_position_changed(slice_index : int):
	_update_slices(slice_index)

func _on_slice_selected(slice_index : int):
	ui_state.set_selection(element_index, slice_index)

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

	_update_slices()

func _instantiate_slices():
	slices = []
	slices.resize(state.slice_count)

	for i in state.slice_count:
		_instantiate_slice(i)

func _instantiate_slice(index : int):
	slices[index] = shape_scene.instantiate()
	slices_node.add_child(slices[index])

	slices[index].rotation = state.slice_rotation
	slices[index].position = state.slice_position
	slices[index].slice_index = index
	slices[index].element_index = element_index
	slices[index].name = "Slice" + str(index)

	slices[index].position_changed.connect(_on_position_changed)
	slices[index].selected.connect(_on_slice_selected)

func _remove_slice(index : int):
	slices[index].position_changed.disconnect(_on_position_changed)
	slices[index].selected.disconnect(_on_slice_selected)
	slices_node.remove_child(slices[index])
	slices[index].queue_free()

func _update_slices(slice_index : int = 0):
	var slice = slices[slice_index]
	var origin_radius = sqrt(pow(slice.position.x, 2) + pow(slice.position.y, 2))
	var origin_theta = atan2(slice.position.y, slice.position.x)
	var theta_increment = deg_to_rad(360.0 / state.slice_count)

	for i in state.slice_count:
		var theta = (slice_index - i) * theta_increment
		var slice_position = (origin_radius * Vector2.from_angle(theta + origin_theta))

		if (i != slice_index):
			slices[i].position = slice_position - position
		slices[i].rotation = origin_theta + deg_to_rad(state.slice_rotation) + theta

	# Update the state
	state.radius = origin_radius
	state.slice_rotation = slices[0].rotation
	state.slice_position = slices[0].position
