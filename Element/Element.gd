class_name Element
extends Node2D

# References
@export var ui_state : UIState
@export var shape_scene : PackedScene
@export var slices_node : Node2D

# Settings
@export var element_index : int
@export var slice_count : int
@export var initial_radius : float
@export var shape_rotation : float

# Internal
var slices
var is_selected

func init(element_index : int):
	self.element_index = element_index

	_instantiate_slices()
	_update_slices()

func _on_position_changed(slice_index : int):
	_update_slices(slice_index)

func _on_slice_selected(slice_index : int):
	ui_state.set_selection(element_index, slice_index)

func _instantiate_slices():
	slices = []
	slices.resize(slice_count)

	for i in slice_count:
		slices[i] = shape_scene.instantiate()
		slices_node.add_child(slices[i])

		slices[i].slice_index = i
		slices[i].element_index = element_index
		slices[i].name = "Slice" + str(i)
		slices[i].allow_drag = true
		slices[i].position = Vector2(initial_radius, 0)

		slices[i].position_changed.connect(_on_position_changed)
		slices[i].selected.connect(_on_slice_selected)

func _update_slices(slice_index : int = 0):
	var slice = slices[slice_index]
	var origin_radius = sqrt(pow(slice.position.x, 2) + pow(slice.position.y, 2))
	var origin_theta = atan2(slice.position.y, slice.position.x)
	var theta_increment = deg_to_rad(360.0 / slice_count)

	for i in slice_count:
		var theta = (slice_index - i) * theta_increment
		var slice_position = (origin_radius * Vector2.from_angle(theta + origin_theta))

		if (i != slice_index):
			slices[i].position = slice_position - position
		slices[i].rotation = origin_theta + deg_to_rad(shape_rotation) + theta
