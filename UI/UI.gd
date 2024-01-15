class_name UI
extends Control

# References
@export var world : World
@export var ui_state : UIState
@export var save_button : Button
@export var file_dialog : FileDialog
@export var background_color_input : ColorPickerButton
@export var slice_count_input : SpinBox
@export var slice_color_input : ColorPickerButton
@export var slice_outline_width_input : SpinBox
@export var slice_outline_color_input : ColorPickerButton
@export var slice_rotation_input : SpinBox
@export var about_dialog : AcceptDialog

# Internal
var background_color_picker_popup : PopupPanel
var slice_color_picker_popup : PopupPanel
var outline_color_picker_popup : PopupPanel
var current_element_state : ElementState
var current_element_index : int
var current_slice_index : int
var current_slice : Slice

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

	_update_save_button_text()
	_update_window_title()

	world.document.document_state_replaced.connect(_on_document_state_replaced)

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		event.command_or_control_autoremap = true

		if event.alt_pressed:
			if event.keycode == KEY_ENTER:
				_toggle_full_screen()

		if event.ctrl_pressed:
			if event.keycode == KEY_Z and not event.shift_pressed:
				_on_undo_button_pressed()
			elif event.keycode == KEY_Z and event.shift_pressed:
				_on_redo_button_pressed()
			elif event.keycode == KEY_S:
				_on_save_button_pressed()
			elif event.keycode == KEY_O:
				_on_load_button_pressed()
			elif event.keycode == KEY_X:
				_on_clear_button_pressed()
			elif event.keycode == KEY_UP:
				slice_count_input.value += 1
			elif event.keycode == KEY_DOWN:
				slice_count_input.value -= 1

func _update_save_button_text() -> void:
	if ui_state.document_is_dirty:
		save_button.text = "Save (edited)"
	else:
		save_button.text = "Save"

func _update_edit_form() -> void:
	if current_element_state != null:
		slice_count_input.value = current_element_state.slice_count
		slice_color_input.color = current_element_state.slice_color
		slice_outline_width_input.value = current_element_state.slice_outline_width
		slice_outline_color_input.color = current_element_state.slice_outline_color
		slice_rotation_input.value = rad_to_deg(current_slice.rotation)

func _update_window_title() -> void:
	if ui_state.document_is_dirty:
		save_button.text = "Save (edited)"
		DisplayServer.window_set_title("Symmetar - " + ui_state.document_name + " (edited)")
	else:
		save_button.text = "Save"
		DisplayServer.window_set_title("Symmetar - " + ui_state.document_name)
	pass

func _toggle_full_screen() -> void:
	var current_mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

#region External signal handlers
func _on_document_state_replaced() -> void:
	world.document.state.background_color_changed.connect(_on_background_color_state_changed)

func _on_selection_changed() -> void:
	if ui_state.selected_element_index >= 0:
		if current_element_state == null or current_element_index != ui_state.selected_element_index:
			current_element_state = world.document.get_element_state(ui_state.selected_element_index)
			current_element_index = ui_state.selected_element_index

			if !current_element_state.slice_rotation_changed.is_connected(_on_slice_rotation_state_changed):
				current_element_state.slice_rotation_changed.connect(_on_slice_rotation_state_changed)

		if current_slice == null or current_slice_index != ui_state.selected_slice_index:
			current_slice = world.document.get_slice(ui_state.selected_element_index, ui_state.selected_slice_index)
	elif current_element_state != null:
		current_element_state.slice_rotation_changed.disconnect(_on_slice_rotation_state_changed)
		current_element_state = null
		current_slice = null

	_update_edit_form()

func _on_slice_rotation_state_changed() -> void:
	if ui_state.selected_element_index >= 0:
		var slice : Slice = world.document.get_slice(ui_state.selected_element_index, ui_state.selected_slice_index)
		slice_rotation_input.set_value_no_signal(rad_to_deg(slice.rotation))

func _on_background_color_state_changed() -> void:
	background_color_input.color = world.document.state.background_color

func _on_document_is_dirty_changed() -> void:
	_update_save_button_text()
	_update_window_title()
#endregion

#region UI signal handlers
func _on_save_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.current_file = ui_state.document_name
	file_dialog.show()

func _on_file_selected(path : String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		world.document.save_document(path)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		world.document.load_document(path)

func _on_load_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_file = ""
	file_dialog.show()

func _on_add_button_pressed() -> void:
	var element_state : ElementState = ElementState.new(
		slice_count_input.value as int,
		deg_to_rad(slice_rotation_input.value),
		Vector2(200, 0),
		slice_color_input.color,
		slice_outline_width_input.value,
		slice_outline_color_input.color,
	)

	world.document.add_new_element(element_state)
	world.undo_manager.register_diff()

func _on_clear_button_pressed() -> void:
	world.document.clear_elements()
	world.undo_manager.register_diff()

func _on_slice_count_changed(value : float) -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		var slice_count_changed : bool = element_state.slice_count != value

		if slice_count_changed:
			element_state.slice_count = value as int
			world.undo_manager.register_diff()

func _on_background_color_changed(value : Color) -> void:
	var background_color_changed : bool = world.document.state.background_color != value

	if background_color_changed:
		world.document.state.background_color = value

func _on_background_color_picker_visibility_changed() -> void:
	ui_state.background_color_picker_visible = background_color_input.get_popup().visible
	world.undo_manager.register_diff()

func _on_slice_color_changed(value : Color) -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		var slice_color_changed : bool = element_state.slice_color != value

		if slice_color_changed:
			element_state.slice_color = value

func _on_slice_color_picker_visibility_changed() -> void:
	ui_state.slice_color_picker_visible = slice_color_input.get_popup().visible

	if ui_state.selected_element_index >= 0:
		world.undo_manager.register_diff()

func _on_slice_outline_width_changed(value : float) -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		var outline_width_changed : bool = element_state.slice_outline_width != value

		if outline_width_changed:
			element_state.slice_outline_width = value as int
			world.undo_manager.register_diff()

func _on_slice_outline_color_changed(value : Color) -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		var outline_color_changed : bool = element_state.slice_outline_color != value

		if outline_color_changed:
			element_state.slice_outline_color = value

func _on_slice_outline_color_picker_visibility_changed() -> void:
	ui_state.slice_outline_color_picker_visible = slice_outline_color_input.get_popup().visible

	if ui_state.selected_element_index >= 0:
		world.undo_manager.register_diff()

func _on_slice_rotation_changed(value : float) -> void:
	if ui_state.selected_element_index >= 0:
		var slice : Slice = world.document.get_slice(ui_state.selected_element_index, ui_state.selected_slice_index)
		slice.set_slice_rotation(deg_to_rad(value))

func _on_undo_button_pressed() -> void:
	world.undo_manager.undo()
	_update_edit_form()

func _on_redo_button_pressed() -> void:
	world.undo_manager.redo()
	_update_edit_form()

func _on_about_button_pressed() -> void:
	about_dialog.show()
#endregion
