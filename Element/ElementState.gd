class_name ElementState
extends Resource

# Data
@export var index : int
@export var radius : float
@export var slice_count : int:
	set(value):
		var value_changed = value != slice_count
		if value_changed:
			slice_count = value
			slice_count_changed.emit()
@export var slice_rotation : float
@export var slice_position : Vector2
@export var slice_color : Color:
	set(value):
		var value_changed = value != slice_color
		if value_changed:
			slice_color = value
			slice_color_changed.emit()

# Signals
signal slice_count_changed
signal slice_color_changed

static func get_exported_properties() -> Array[String]:
	var exported_properties : Array[String] = []
	for property in ElementState.new().get_property_list():
		if property["usage"] == PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE :
			exported_properties.push_back(property["name"])

	return exported_properties

func get_diff(other_element : ElementState) -> ElementState:
	var element_properties = ElementState.get_exported_properties()
	var element_diff = ElementState.new()

	for property in element_properties:
		element_diff[property] = self[property] - other_element[property]

	return element_diff

func apply_diff(element_diff : ElementState, direction : int) -> void:
	var element_properties = ElementState.get_exported_properties()
	for property in element_properties:
		self[property] += element_diff[property] * direction
