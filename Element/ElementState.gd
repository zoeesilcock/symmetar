class_name ElementState
extends Resource

# Data
@export var index: int

@export var slice_count: int:
	set(value):
		if value != slice_count:
			slice_count = value
			slice_count_changed.emit()

@export var slice_shape: Shapes.ShapeIndex:
	set(value):
		if value != slice_shape:
			slice_shape = value
			slice_shape_changed.emit()

@export var slice_rotation: float:
	set(value):
		if value != slice_rotation:
			slice_rotation = value
			slice_rotation_changed.emit()

@export var slice_position: Vector2:
	set(value):
		if value != slice_position:
			slice_position = value
			slice_position_changed.emit()

@export var slice_theta: float:
	set(value):
		if value != slice_theta:
			slice_theta = value
			slice_theta_changed.emit()

@export var slice_scale: Vector2:
	set(value):
		if value != slice_scale:
			slice_scale = value
			slice_scale_changed.emit()

@export var slice_pivot: Vector2:
	set(value):
		if value != slice_pivot:
			slice_pivot = value
			slice_pivot_changed.emit()

@export var slice_color: Color:
	set(value):
		if value != slice_color:
			slice_color = value
			slice_color_changed.emit()

@export var slice_outline_width: float:
	set(value):
		if value != slice_outline_width:
			slice_outline_width = value
			slice_outline_width_changed.emit()

@export var slice_outline_color: Color:
	set(value):
		if value != slice_outline_color:
			slice_outline_color = value
			slice_outline_color_changed.emit()

# Signals
signal slice_count_changed
signal slice_shape_changed
signal slice_rotation_changed
signal slice_position_changed
signal slice_theta_changed
signal slice_scale_changed
signal slice_pivot_changed
signal slice_color_changed
signal slice_outline_width_changed
signal slice_outline_color_changed

static func empty() -> ElementState:
	return ElementState.new(
		1,
		Shapes.ShapeIndex.TRIGON,
		Vector2.ONE,
		0.0,
		Vector2(),
		0.0,
		Color()
	)

func _init(
		p_slice_count: int=8,
		p_slice_shape: Shapes.ShapeIndex=Shapes.ShapeIndex.TRIGON,
		p_slice_scale: Vector2=Vector2.ONE,
		p_slice_rotation: float=0,
		p_slice_position: Vector2=Vector2(),
		p_slice_theta: float=0,
		p_slice_color: Color=Color("#e85500"),
		p_slice_outline_width: float=2.0,
		p_slice_outline_color: Color=("#fff500")) -> void:
	slice_count = p_slice_count
	slice_shape = p_slice_shape
	slice_scale = p_slice_scale
	slice_rotation = p_slice_rotation
	slice_position = p_slice_position
	slice_theta = p_slice_theta
	slice_color = p_slice_color
	slice_outline_width = p_slice_outline_width
	slice_outline_color = p_slice_outline_color

static func get_exported_properties() -> Array[String]:
	var exported_properties: Array[String] = []
	for property: Dictionary in ElementState.new().get_property_list():
		if (property["usage"] == PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE or
			property["usage"] == PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_CLASS_IS_ENUM):
			exported_properties.push_back(property["name"])

	return exported_properties

func get_diff(other_element: ElementState) -> ElementStateDiff:
	var element_diff: ElementStateDiff = ElementStateDiff.new(index)

	for property: String in ElementState.get_exported_properties():
		element_diff.try_add_diff(property, self[property] - other_element[property])

	if len(element_diff.changes) > 0:
		return element_diff
	else:
		return null

func apply_diff(element_diff: ElementStateDiff, direction: int) -> void:
	for diff: ElementPropertyDiff in element_diff.changes:
		self[diff.property] += diff.change * direction
