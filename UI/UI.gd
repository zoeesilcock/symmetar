class_name UI
extends CanvasLayer

# References
@export var world : World
@export var ui_state : UIState
@export var file_dialog : FileDialog
@export var slice_count_input : SpinBox
@export var slice_color_input : ColorPickerButton

func _ready():
	ui_state.selection_changed.connect(_on_selection_changed)
	slice_color_input.get_picker().color_changed.connect(_on_slice_color_changed)

	file_dialog.set_filters(PackedStringArray(["*.smtr ; Symmetar Files"]))

func _input(event : InputEvent):
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

func _on_save_button_pressed():
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.show()

func _on_file_selected(path : String):
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		world.document.save_document(path)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		world.document.load_document(path)

func _on_load_button_pressed():
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.show()

func _on_add_button_pressed():
	var element_state = ElementState.new(
		200.0,
		slice_count_input.value,
		0.0,
		Vector2(200, 0),
		slice_color_input.color
	)

	world.document.add_new_element(element_state)
	world.undo_manager.register_diff()

func _on_clear_button_pressed():
	world.document.clear_elements()
	world.undo_manager.register_diff()

func _on_selection_changed():
	if ui_state.selected_element_index >= 0:
		var element_state = world.document.get_element_state(ui_state.selected_element_index)
		slice_count_input.value = element_state.slice_count
		slice_color_input.color = element_state.slice_color

func _on_slice_count_changed(value : float):
	if ui_state.selected_element_index >= 0:
		var element_state = world.document.get_element_state(ui_state.selected_element_index)
		var slice_count_changed = element_state.slice_count != value

		if slice_count_changed:
			element_state.slice_count = value
			world.undo_manager.register_diff()

func _on_slice_color_changed(value : Color):
	if ui_state.selected_element_index >= 0:
		var element_state = world.document.get_element_state(ui_state.selected_element_index)
		var slice_color_changed = element_state.slice_color != value

		if slice_color_changed:
			element_state.slice_color = value
			world.undo_manager.register_diff()

func _on_undo_button_pressed():
	world.undo_manager.undo()

func _on_redo_button_pressed():
	world.undo_manager.redo()
