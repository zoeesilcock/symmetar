class_name ElementStateDiff
extends Resource

var index: int
var changes: Array[ElementPropertyDiff]

func _init(p_element_index: int=0) -> void:
	index = p_element_index
	changes = []

func try_add_diff(property: String, diff: Variant) -> void:
	var property_type: int = typeof(diff)
	if ((property_type == TYPE_INT and diff != 0) or
		(property_type == TYPE_FLOAT and diff != 0.0) or
		(property_type == TYPE_VECTOR2 and (diff.x != 0.0 or diff.y != 0.0)) or
		(property_type == TYPE_COLOR and (diff.r != 0.0 or diff.g != 0.0 or diff.b != 0.0 or diff.a != 0.0)) or
		(property == "slice_shape" and diff != 0)):
		changes.push_back(ElementPropertyDiff.new(property, diff))

