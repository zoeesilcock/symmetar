extends Node2D

# References
@export var origin_shape: Shape
@export var slices_node : Node2D

# Settings
@export var slice_count : int
@export var click_radius : int

# Internal
var slices

func _ready():
	origin_shape.allow_drag = true
	origin_shape.position_changed.connect(_on_position_changed)

	_instantiate_slices()
	_update_slices()

func _on_position_changed():
	_update_slices()

func _instantiate_slices():
	slices = []
	slices.resize(slice_count)

	for i in range(1, slice_count):
		slices[i] = origin_shape.duplicate()
		slices[i].allow_drag = false
		slices_node.add_child(slices[i])

func _update_slices():
	var origin_radius = sqrt(pow(origin_shape.position.x, 2) + pow(origin_shape.position.y, 2))
	var origin_theta = atan2(origin_shape.position.y, origin_shape.position.x)
	var origin_rotation = rad_to_deg(origin_shape.rotation)
	var theta_increment = deg_to_rad(360 / slice_count)

#	print(
#		"Origin -" +
#		" radius: " + str(origin_radius) +
#		" theta: " + str(origin_radius) +
#		" rotation: " + str(origin_rotation)
#	)

	for i in range(1, slice_count):
		var theta = i * theta_increment
		var slice_position = (origin_radius * Vector2.from_angle(theta + origin_theta))

		slices[i].position = slice_position - position
		slices[i].rotation = origin_rotation + theta
