class_name DocumentStateDiff
extends Resource

@export var element_count_change: int
@export var element_diffs: Array[ElementStateDiff]
@export var background_color_change: Color

@export_multiline var diff_preview: String:
	get:
		var preview: String = "Diffs:\n"

		for diff:ElementStateDiff in element_diffs:
			preview += str(diff.index) + ": "
			for change: ElementPropertyDiff in diff.changes:
				preview += "  * " + change.property + " = " + str(change.change) + "\n"

		return preview

func _init(
		p_element_count_change: int=0,
		p_element_diffs: Array[ElementStateDiff]=[],
		p_background_color_change: Color=Color.BLACK) -> void:
	element_count_change = p_element_count_change
	element_diffs = p_element_diffs
	background_color_change = p_background_color_change
