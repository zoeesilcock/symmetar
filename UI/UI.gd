class_name UI
extends CanvasLayer

# References
@export var world : World
@export var ui_state : UIState
@export var file_dialog : FileDialog

func _ready():
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
	world.document.add_new_element()

func _on_clear_button_pressed():
	world.document.clear_elements()
