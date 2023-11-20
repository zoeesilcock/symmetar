class_name UI
extends CanvasLayer

# References
@export var world : World
@export var ui_state : UIState
@export var file_dialog : FileDialog
@export var slice_count_input : SpinBox

func _ready():
	ui_state.selection_changed.connect(_on_selection_changed)
	file_dialog.set_filters(PackedStringArray(["*.smtr ; Symmetar Files"]))

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
	var element_state = ElementState.new()
	element_state.slice_count = 8
	element_state.radius = 200
	element_state.slice_position = Vector2(element_state.radius, 0)
	world.document.add_new_element(element_state)
	world.undo_manager.register_diff()

func _on_clear_button_pressed():
	world.document.clear_elements()
	world.undo_manager.register_diff()

func _on_selection_changed():
	if ui_state.selected_element_index >= 0:
		var element_state = world.document.get_element_state(ui_state.selected_element_index)
		slice_count_input.value = element_state.slice_count
	else:
		slice_count_input.value = 0

func _on_slice_count_changed(value : float):
	if ui_state.selected_element_index >= 0:
		var element_state = world.document.get_element_state(ui_state.selected_element_index)
		var slice_count_changed = element_state.slice_count != value
		element_state.slice_count = value

		if slice_count_changed:
			world.undo_manager.register_diff()

func _on_undo_button_pressed():
	world.undo_manager.undo()

func _on_redo_button_pressed():
	world.undo_manager.redo()
