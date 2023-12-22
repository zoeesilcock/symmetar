class_name Document
extends Node2D

# State
@export var state : DocumentState

# References
@export var ui_state : UIState
@export var undo_manager : UndoManager
@export var element_scene : PackedScene
@export var elements_node : Node2D

# Internal
var elements : Array[Node]

func _ready() -> void:
	elements = []

	state = DocumentState.new()
	state.element_count_changed.connect(_on_element_count_changed)

func load_document(path : String) -> void:
	state.element_count_changed.disconnect(_on_element_count_changed)
	clear_elements()

	state = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as DocumentState
	state.element_count_changed.connect(_on_element_count_changed)
	_instantiate_elements()

	ui_state.document_name = path.get_file()
	ui_state.document_is_dirty = false

func save_document(path : String) -> void:
	ResourceSaver.save(state, path)

	ui_state.document_name = path.get_file()
	ui_state.document_is_dirty = false

func get_element_state(index : int) -> ElementState:
	return state.elements[index]

func add_new_element(element_state : ElementState) -> void:
	var new_element : Node = element_scene.instantiate()
	var element_index : int = len(elements)

	elements_node.add_child(new_element)
	elements.push_back(new_element)
	state.elements.push_back(element_state)

	element_state.index = element_index
	new_element.init(element_state)
	new_element.state_changed.connect(_on_element_state_changed)

	ui_state.set_selection(element_index, 0)
	ui_state.document_is_dirty = true

func remove_element(index : int) -> void:
	elements_node.remove_child(elements[index])
	elements.remove_at(index)
	_update_element_indexes()

func clear_elements() -> void:
	_remove_all_elements()
	state.elements = []
	ui_state.document_is_dirty = true

func _on_element_count_changed() -> void:
	_remove_all_elements()
	_instantiate_elements()
	ui_state.document_is_dirty = true

func _on_element_state_changed(_element_index : int) -> void:
	undo_manager.register_diff()
	ui_state.document_is_dirty = true

func _remove_all_elements() -> void:
	for element : Node in elements:
		elements_node.remove_child(element)

	elements = []

func _instantiate_elements() -> void:
	elements.resize(len(state.elements))

	for element_index :int in len(state.elements):
		_instantiate_element(element_index)

func _instantiate_element(element_index : int) -> void:
	var loaded_element : Node = element_scene.instantiate()
	elements_node.add_child(loaded_element)
	elements[element_index] = loaded_element

	loaded_element.init(state.elements[element_index])
	loaded_element.state_changed.connect(_on_element_state_changed)

func _update_element_indexes() -> void:
	for element_index : int in len(elements):
		elements[element_index].index = element_index
