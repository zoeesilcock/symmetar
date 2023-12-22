class_name UI
extends CanvasLayer

# References
@export var world : World
@export var ui_state : UIState
@export var save_button : Button
@export var file_dialog : FileDialog
@export var slice_count_input : SpinBox
@export var slice_color_input : ColorPickerButton

var slice_color_picker_popup : PopupPanel

func _ready() -> void:
	ui_state.init()
	ui_state.selection_changed.connect(_on_selection_changed)
	ui_state.document_is_dirty_changed.connect(_on_document_is_dirty_changed)

	slice_color_picker_popup = slice_color_input.get_popup()
	slice_color_picker_popup.visibility_changed.connect(_on_slice_color_picker_visibility_changed)
	slice_color_input.color_changed.connect(_on_slice_color_changed)

	file_dialog.set_filters(PackedStringArray(["*.smtr ; Symmetar Files"]))

	_update_save_button_text()

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		event.command_or_control_autoremap = true

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
			elif event.keycode == KEY_A:
				_on_add_button_pressed()
			elif event.keycode == KEY_UP:
				slice_count_input.value += 1
			elif event.keycode == KEY_DOWN:
				slice_count_input.value -= 1

func _on_save_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.show()

func _on_file_selected(path : String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		world.document.save_document(path)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		world.document.load_document(path)

func _on_load_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.show()

func _on_add_button_pressed() -> void:
	var element_state : ElementState = ElementState.new(
		slice_count_input.value as int,
		0.0,
		Vector2(200, 0),
		slice_color_input.color
	)

	world.document.add_new_element(element_state)
	world.undo_manager.register_diff()

func _on_clear_button_pressed() -> void:
	world.document.clear_elements()
	world.undo_manager.register_diff()

func _on_selection_changed() -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		slice_count_input.value = element_state.slice_count
		slice_color_input.color = element_state.slice_color

func _on_document_is_dirty_changed() -> void:
	_update_save_button_text()

func _update_save_button_text() -> void:
	if ui_state.document_is_dirty:
		save_button.text = "Save (edited)"
	else:
		save_button.text = "Save"

func _on_slice_count_changed(value : float) -> void:
	if ui_state.selected_element_index >= 0:
		var element_state : ElementState = world.document.get_element_state(ui_state.selected_element_index)
		var slice_count_changed : bool = element_state.slice_count != value

		if slice_count_changed:
			element_state.slice_count = value as int
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

func _on_undo_button_pressed() -> void:
	world.undo_manager.undo()

func _on_redo_button_pressed() -> void:
	world.undo_manager.redo()
