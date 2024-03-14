class_name UI
extends Control

# References
@export var world: World
@export var ui_state: UIState
@export var shapes: Shapes
@export var menu_bar: AppMenuBar
@export var side_bar: Panel
@export var file_dialog: FileDialog
@export var background_color_input: ColorPickerButton
@export var zoom_input: SpinBox
@export var position_x_input: SpinBox
@export var position_y_input: SpinBox
@export var slice_count_input: SpinBox
@export var slice_shape_input: OptionButton
@export var slice_color_input: ColorPickerButton
@export var slice_outline_width_input: SpinBox
@export var slice_outline_color_input: ColorPickerButton
@export var slice_scale_x_input: SpinBox
@export var slice_scale_y_input: SpinBox
@export var slice_rotation_input: SpinBox
@export var slice_radius_input: SpinBox
@export var slice_theta_input: SpinBox
@export var about_dialog: AcceptDialog

# Internal
var background_color_picker_popup: PopupPanel
var slice_color_picker_popup: PopupPanel
var outline_color_picker_popup: PopupPanel
var current_element_state: ElementState
var current_element_index: int
var current_slice_index: int
var current_slice: Slice

func _ready() -> void:
	ui_state.init()
	ui_state.selection_changed.connect(_on_selection_changed)
	ui_state.document_is_dirty_changed.connect(_on_document_is_dirty_changed)

	background_color_picker_popup = background_color_input.get_popup()
	background_color_picker_popup.visibility_changed.connect(_on_background_color_picker_visibility_changed)
	background_color_input.color_changed.connect(_on_background_color_changed)

	slice_color_picker_popup = slice_color_input.get_popup()
	slice_color_picker_popup.visibility_changed.connect(_on_slice_color_picker_visibility_changed)
	slice_color_input.color_changed.connect(_on_slice_color_changed)

	outline_color_picker_popup = slice_outline_color_input.get_popup()
	outline_color_picker_popup.visibility_changed.connect(_on_slice_outline_color_picker_visibility_changed)
	slice_outline_color_input.color_changed.connect(_on_slice_outline_color_changed)

	file_dialog.set_filters(PackedStringArray(["*.smtr ; Symmetar Files"]))

	_build_shape_dropdown()
	_update_window_title()

	world.document.document_state_replaced.connect(_on_document_state_replaced)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		event.command_or_control_autoremap = true

		if event.ctrl_pressed:
			if event.keycode == KEY_UP:
				slice_count_input.value += 1
			elif event.keycode == KEY_DOWN:
				slice_count_input.value -= 1

func _update_edit_form() -> void:
	if current_element_state != null:
		slice_count_input.set_value_no_signal(current_element_state.slice_count)
		slice_shape_input.select(current_element_state.slice_shape)
		slice_color_input.color = current_element_state.slice_color
		slice_outline_width_input.set_value_no_signal(current_element_state.slice_outline_width)
		slice_outline_color_input.color = current_element_state.slice_outline_color
		slice_scale_x_input.set_value_no_signal(current_slice.slice_scale.x * 100.0)
		slice_scale_y_input.set_value_no_signal(current_slice.slice_scale.y * 100.0)
		slice_rotation_input.set_value_no_signal(rad_to_deg(current_slice.rotation))
		slice_radius_input.set_value_no_signal(current_slice.get_radius())
		slice_theta_input.set_value_no_signal(rad_to_deg(current_slice.get_theta()))

func _update_current_selection() -> void:
	ui_state.fix_missing_selections(len(world.document.elements))

func _build_shape_dropdown() -> void:
	for shape_key: String in Shapes.ShapeIndex:
		var shape_info: ShapeInfo = shapes.get_shape_info(Shapes.ShapeIndex[shape_key])
		slice_shape_input.add_item(shape_info.name, shape_info.index)
		slice_shape_input.set_item_icon(shape_info.index, shape_info.icon)

func _update_window_title() -> void:
	if ui_state.document_is_dirty:
		DisplayServer.window_set_title("Symmetar - " + ui_state.document_name + " (edited)")
	else:
		DisplayServer.window_set_title("Symmetar - " + ui_state.document_name)
	pass

func _toggle_full_screen() -> void:
	var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

func _toggle_ui() -> void:
	visible = !visible
	ui_state.ui_is_visible = visible

#region External signal handlers
func _on_document_state_replaced() -> void:
	# TODO: Is this where we set the initial values of the form?
	world.document.state.background_color_changed.connect(_on_background_color_state_changed)
	world.document.state.zoom_changed.connect(_on_zoom_state_changed)
	world.document.state.pan_position_changed.connect(_on_pan_position_state_changed)

func _on_zoom_state_changed() -> void:
	zoom_input.set_value_no_signal(world.document.state.zoom * 100.0)

func _on_pan_position_state_changed() -> void:
	position_x_input.set_value_no_signal(world.document.state.pan_position.x)
	position_y_input.set_value_no_signal(world.document.state.pan_position.y)

func _on_selection_changed() -> void:
	var main_selection: UISelection = ui_state.main_selected_item

	if main_selection != null:
		if current_element_state == null or current_element_index != main_selection.element_index:
			current_element_state = world.document.get_element_state(main_selection.element_index)
			current_element_index = main_selection.element_index
			current_slice = world.document.get_slice(main_selection.element_index, main_selection.slice_index)
			current_slice_index = main_selection.slice_index

			if !current_element_state.slice_scale_changed.is_connected(_on_slice_scale_state_changed):
				current_element_state.slice_scale_changed.connect(_on_slice_scale_state_changed)

			if !current_element_state.slice_rotation_changed.is_connected(_on_slice_rotation_state_changed):
				current_element_state.slice_rotation_changed.connect(_on_slice_rotation_state_changed)

			if !current_element_state.slice_position_changed.is_connected(_on_slice_position_state_changed):
				current_element_state.slice_position_changed.connect(_on_slice_position_state_changed)
		elif current_slice == null or current_slice_index != main_selection.slice_index:
			current_slice = world.document.get_slice(main_selection.element_index, main_selection.slice_index)
			current_slice_index = main_selection.slice_index

		menu_bar.set_remove_enabled(true)
	elif current_element_state != null:
		current_element_state.slice_scale_changed.disconnect(_on_slice_scale_state_changed)
		current_element_state.slice_rotation_changed.disconnect(_on_slice_rotation_state_changed)
		current_element_state = null
		current_slice = null

		menu_bar.set_remove_enabled(false)

	_update_edit_form()

func _for_all_selected_slices(lambda: Callable) -> void:
	for selection: UISelection in ui_state.selected_items:
		var slice: Slice = world.document.get_slice(selection.element_index, selection.slice_index)
		lambda.call(slice)

func _for_all_selected_elements(lambda: Callable) -> void:
	for selection: UISelection in ui_state.selected_items:
		var element_state: ElementState = world.document.get_element_state(selection.element_index)
		lambda.call(element_state)

func _on_slice_position_state_changed() -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice_radius_input.set_value_no_signal(slice.get_radius())
		slice_theta_input.set_value_no_signal(rad_to_deg(slice.get_theta()))
	)

func _on_slice_scale_state_changed() -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice_scale_x_input.set_value_no_signal(slice.slice_scale.x * 100.0)
		slice_scale_y_input.set_value_no_signal(slice.slice_scale.y * 100.0)
	)

func _on_slice_rotation_state_changed() -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice_rotation_input.set_value_no_signal(rad_to_deg(slice.rotation))
	)

func _on_background_color_state_changed() -> void:
	background_color_input.color = world.document.state.background_color

func _on_document_is_dirty_changed() -> void:
	_update_window_title()
#endregion

#region UI signal handlers
func _on_save_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.current_file = ui_state.document_name
	file_dialog.show()

func _on_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		world.document.save_document(path)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		world.document.load_document(path)

func _on_load_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_file = ""
	file_dialog.show()

func _on_add_button_pressed() -> void:
	var shape_info: ShapeInfo = shapes.get_shape_info(slice_shape_input.selected)
	var element_state: ElementState = ElementState.new(
		slice_count_input.value as int,
		shape_info.index,
		Vector2(slice_scale_x_input.value / 100.0, slice_scale_y_input.value / 100.0),
		deg_to_rad(slice_rotation_input.value),
		Vector2(slice_radius_input.value, 0),
		slice_color_input.color,
		slice_outline_width_input.value,
		slice_outline_color_input.color,
	)

	world.document.add_new_element(element_state)
	world.undo_manager.register_diff()

func _on_remove_button_pressed() -> void:
	_for_all_selected_elements(func(element_state: ElementState) -> void:
		world.document.remove_element(element_state.index)
	)

func _on_clear_button_pressed() -> void:
	world.document.clear_elements()
	world.undo_manager.register_diff()

func _on_slice_count_changed(value: float) -> void:
	var any_change: bool

	_for_all_selected_elements(func(element_state: ElementState) -> void:
		var slice_count_changed: bool = element_state.slice_count != value

		if slice_count_changed:
			element_state.slice_count = value as int
			any_change = true
	)

	if any_change:
		world.undo_manager.register_diff()

func _on_background_color_changed(value: Color) -> void:
	var background_color_changed: bool = world.document.state.background_color != value

	if background_color_changed:
		world.document.state.background_color = value

func _on_background_color_picker_visibility_changed() -> void:
	ui_state.background_color_picker_visible = background_color_input.get_popup().visible
	world.undo_manager.register_diff()

func _on_zoom_changed(value: float) -> void:
	world.document.state.zoom = value / 100.0
	world.undo_manager.register_diff()

func _on_reset_zoom_button_pressed() -> void:
	world.document.state.zoom = 1
	world.undo_manager.register_diff()

func _on_position_x_changed(value: float) -> void:
	world.document.state.pan_position.x = value
	world.undo_manager.register_diff()

func _on_position_y_changed(value: float) -> void:
	world.document.state.pan_position.y = value
	world.undo_manager.register_diff()

func _on_reset_position_button_pressed() -> void:
	world.document.state.pan_position = Vector2.ZERO
	world.undo_manager.register_diff()

func _on_slice_shape_changed(value: int) -> void:
	_for_all_selected_elements(func(element_state: ElementState) -> void:
		var slice_shape_changed: bool = element_state.slice_shape != value

		if slice_shape_changed:
			element_state.slice_shape = value as Shapes.ShapeIndex
	)

func _on_slice_color_changed(value: Color) -> void:
	_for_all_selected_elements(func(element_state: ElementState) -> void:
		var slice_color_changed: bool = element_state.slice_color != value

		if slice_color_changed:
			element_state.slice_color = value
	)

func _on_slice_color_picker_visibility_changed() -> void:
	ui_state.slice_color_picker_visible = slice_color_input.get_popup().visible

	if len(ui_state.selected_items) > 0:
		world.undo_manager.register_diff()

func _on_slice_outline_width_changed(value: float) -> void:
	var any_change: bool

	_for_all_selected_elements(func(element_state: ElementState) -> void:
		var outline_width_changed: bool = element_state.slice_outline_width != value

		if outline_width_changed:
			element_state.slice_outline_width = value as int
			any_change = true
	)

	if any_change:
		world.undo_manager.register_diff()


func _on_slice_outline_color_changed(value: Color) -> void:
	_for_all_selected_elements(func(element_state: ElementState) -> void:
		var outline_color_changed: bool = element_state.slice_outline_color != value

		if outline_color_changed:
			element_state.slice_outline_color = value
	)

func _on_slice_outline_color_picker_visibility_changed() -> void:
	ui_state.slice_outline_color_picker_visible = slice_outline_color_input.get_popup().visible

	if len(ui_state.selected_items) > 0:
		world.undo_manager.register_diff()

func _on_slice_scale_x_changed(value: float) -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_slice_scale(Vector2(value / 100.0, slice.slice_scale.y))
	)

func _on_slice_scale_y_changed(value: float) -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_slice_scale(Vector2(slice.slice_scale.x, value / 100.0))
	)

func _on_reset_slice_scale_button_pressed() -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_slice_scale(Vector2.ONE)
	)

func _on_slice_rotation_changed(value: float) -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_slice_rotation(deg_to_rad(value))
	)

func _on_slice_radius_changed(value: float) -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_radius(value)
	)

	world.undo_manager.register_diff()
	ui_state.document_is_dirty = true

func _on_slice_theta_changed(value: float) -> void:
	_for_all_selected_slices(func(slice: Slice) -> void:
		slice.set_theta(deg_to_rad(value))
	)

	world.undo_manager.register_diff()
	ui_state.document_is_dirty = true

func _on_undo_button_pressed() -> void:
	world.undo_manager.undo()
	_update_current_selection()
	_update_edit_form()

func _on_redo_button_pressed() -> void:
	world.undo_manager.redo()
	_update_current_selection()
	_update_edit_form()

func _on_about_button_pressed() -> void:
	about_dialog.show()
#endregion
