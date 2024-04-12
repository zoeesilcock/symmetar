class_name ElementPropertyDiff
extends Resource

var property: String
var change: Variant

func _init(p_property: String, p_change: Variant) -> void:
	property = p_property
	change = p_change

