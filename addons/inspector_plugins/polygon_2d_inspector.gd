@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is Polygon2D

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "polygon":
		var button : Button = Button.new()
		button.text = "Generate circle"
		button.pressed.connect(_on_generate_circle_pressed.bind(object))
		add_custom_control(button)

func _on_generate_circle_pressed(object: Polygon2D) -> void:
	var points: PackedVector2Array = []
	var point_count: int = 64
	var center: Vector2 = Vector2.ZERO
	var radius: float = 50.0
	var theta_increment: float = deg_to_rad(360.0 / point_count)

	for i: int in point_count:
		var theta : float = i * theta_increment

		points.append(center + radius * Vector2.from_angle(theta))
		# points.append(center + radius * Vector2.from_angle(theta - deg_to_rad(90))) # Useful for odd number of points.

	object.polygon = points

func _on_generate_crescent_pressed(object: Polygon2D) -> void:
	var points: PackedVector2Array = []
	var point_count: int = 64
	var center: Vector2 = Vector2.ZERO
	var radius: float = 50.0
	var theta_increment: float = deg_to_rad(360.0 / point_count)

	for i: int in point_count:
		var theta : float = i * theta_increment

		if i <= 32:
			center = Vector2.ZERO
			center = Vector2(6.25, 0)
		else:
			center = Vector2(-6.25, 0)
			var diff: int = i - 32
			theta = (32 - diff) * theta_increment

		# points.append(center + radius * Vector2.from_angle(theta))
		points.append(center + radius * Vector2.from_angle(theta - deg_to_rad(90))) # Useful for odd number of points.

	object.polygon = points

func _on_generate_lens_pressed(object: Polygon2D) -> void:
	var points: PackedVector2Array = []
	var point_count: int = 64
	var center: Vector2 = Vector2.ZERO
	var radius: float = 50.0
	var theta_increment: float = deg_to_rad(360.0 / point_count)

	for i: int in point_count:
		var theta : float = i * theta_increment

		if i <= 32:
			center = Vector2(-25, 0)
		else:
			center = Vector2(25, 0)

		# points.append(center + radius * Vector2.from_angle(theta))
		points.append(center + radius * Vector2.from_angle(theta - deg_to_rad(90))) # Useful for odd number of points.

	object.polygon = points
