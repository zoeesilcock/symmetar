extends Polygon2D

# References
@export var ui_state : UIState

func _ready() -> void:
	ui_state.ui_is_visible_changed.connect(_on_ui_visibility_changed)
	visible = ui_state.ui_is_visible

func _on_ui_visibility_changed() -> void:
	visible = ui_state.ui_is_visible
