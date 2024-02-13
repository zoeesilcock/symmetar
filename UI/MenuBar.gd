extends Panel

# References
@export var ui : UI
@export var ui_state : UIState
@export var file_dialog : FileDialog
@export var about_dialog : AcceptDialog
@export var file_menu : PopupMenu
@export var edit_menu : PopupMenu
@export var view_menu : PopupMenu
@export var help_menu : PopupMenu

enum FILE_MENU {
	OPEN,
	SAVE,
	SEPARATOR,
	QUIT,
}

enum EDIT_MENU {
	UNDO,
	REDO,
	SEPARATOR,
	ADD,
	REMOVE,
	CLEAR,
}

enum VIEW_MENU {
	HIDE_UI,
	FULL_SCREEN,
}

enum HELP_MENU {
	ABOUT
}

func _ready() -> void:
	var modifier : KeyModifierMask = KEY_MASK_CTRL

	if OS.get_name() == "macOS":
		modifier = KEY_MASK_META

	file_menu.set_item_accelerator(FILE_MENU.OPEN, modifier | KEY_O)
	file_menu.set_item_accelerator(FILE_MENU.SAVE, modifier | KEY_S)
	file_menu.set_item_accelerator(FILE_MENU.QUIT, modifier | KEY_Q)

	edit_menu.set_item_accelerator(EDIT_MENU.UNDO, modifier | KEY_Z)
	edit_menu.set_item_accelerator(EDIT_MENU.REDO, modifier | KEY_MASK_SHIFT | KEY_Z)
	edit_menu.set_item_accelerator(EDIT_MENU.ADD, modifier | KEY_N)
	edit_menu.set_item_accelerator(EDIT_MENU.REMOVE, modifier | KEY_BACKSPACE)
	edit_menu.set_item_accelerator(EDIT_MENU.CLEAR, modifier | KEY_X)

	view_menu.set_item_accelerator(VIEW_MENU.HIDE_UI, modifier | KEY_U)
	view_menu.set_item_accelerator(VIEW_MENU.FULL_SCREEN, modifier | KEY_F)

func _on_file_index_pressed(index : int) -> void:
	match index:
		FILE_MENU.OPEN:
			ui._on_load_button_pressed()
		FILE_MENU.SAVE:
			ui._on_save_button_pressed()
		FILE_MENU.QUIT:
			get_tree().quit()

func _on_edit_index_pressed(index : int) -> void:
	match index:
		EDIT_MENU.UNDO:
			ui._on_undo_button_pressed()
		EDIT_MENU.REDO:
			ui._on_redo_button_pressed()
		EDIT_MENU.ADD:
			ui._on_add_button_pressed()
		EDIT_MENU.REMOVE:
			ui._on_remove_button_pressed()
		EDIT_MENU.CLEAR:
			ui._on_clear_button_pressed()

func _on_view_index_pressed(index : int) -> void:
	match index:
		VIEW_MENU.HIDE_UI:
			ui._toggle_ui()
			view_menu.set_item_checked(VIEW_MENU.HIDE_UI, !ui_state.ui_is_visible)
		VIEW_MENU.FULL_SCREEN:
			ui._toggle_full_screen()
			view_menu.set_item_checked(VIEW_MENU.FULL_SCREEN, DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

func _on_help_index_pressed(index : int) -> void:
	match index:
		HELP_MENU.ABOUT:
			ui._on_about_button_pressed()
