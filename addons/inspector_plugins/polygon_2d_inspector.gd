@tool
extends EditorInspectorPlugin

func _can_handle(object : Object) -> bool:
	return object is Polygon2D

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "polygon":
		var button : Button = Button.new()
		button.text = "Generate circle"
		button.pressed.connect(_on_generate_circle_pressed.bind(object))
		add_custom_control(button)

func _on_generate_circle_pressed(object : Polygon2D) -> void:
	var points : PackedVector2Array = []
	var point_count : int = 64
	var radius : float = 50.0
	var theta_increment : float = deg_to_rad(360.0 / point_count)

	for i in point_count:
		var theta : float = i * theta_increment
		points.append(radius * Vector2.from_angle(theta))

	object.polygon = points
