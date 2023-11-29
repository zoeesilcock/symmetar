class_name ElementState
extends Resource

# Data
@export var index : int
@export var radius : float:
	set(value):
		if value != radius:
			radius = value
			radius_changed.emit()

@export var slice_count : int:
	set(value):
		if value != slice_count:
			slice_count = value
			slice_count_changed.emit()

@export var slice_rotation : float:
	set(value):
		if value != slice_rotation:
			slice_rotation = value
			slice_rotation_changed.emit()

@export var slice_position : Vector2:
	set(value):
		if value != slice_position:
			slice_position = value
			slice_position_changed.emit()

@export var slice_color : Color:
	set(value):
		if value != slice_color:
			slice_color = value
			slice_color_changed.emit()

# Signals
signal radius_changed
signal slice_count_changed
signal slice_rotation_changed
signal slice_position_changed
signal slice_color_changed

func _init(p_radius : float = 200.0, p_slice_count : int = 8, p_slice_rotation : float = 0, p_slice_position : Vector2 = Vector2(), p_slice_color : Color = Color("#e85500")) -> void:
	radius = p_radius
	slice_count = p_slice_count
	slice_rotation = p_slice_rotation
	slice_position = p_slice_position
	slice_color = p_slice_color

static func get_exported_properties() -> Array[String]:
	var exported_properties : Array[String] = []
	for property : Dictionary in ElementState.new().get_property_list():
		if property["usage"] == PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE :
			exported_properties.push_back(property["name"])

	return exported_properties

func get_diff(other_element : ElementState) -> ElementState:
	var element_diff : ElementState = ElementState.new()

	for property : String in ElementState.get_exported_properties():
		element_diff[property] = self[property] - other_element[property]

	return element_diff

func apply_diff(element_diff : ElementState, direction : int) -> void:
	for property : String in ElementState.get_exported_properties():
		self[property] += element_diff[property] * direction
