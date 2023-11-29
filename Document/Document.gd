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
	state.element_changed.connect(_on_element_changed)

func load_document(path : String) -> void:
	state.element_changed.disconnect(_on_element_changed)
	clear_elements()

	state = ResourceLoader.load(path)
	state.element_changed.connect(_on_element_changed)
	_instantiate_elements()

func save_document(path : String) -> void:
	ResourceSaver.save(state, path)

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

func remove_element(index : int) -> void:
	elements_node.remove_child(elements[index])
	elements.remove_at(index)
	_update_element_indexes()

func clear_elements() -> void:
	for element : Node in elements:
		elements_node.remove_child(element)

	elements = []

func _on_element_changed() -> void:
	clear_elements()
	_instantiate_elements()

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

func _on_element_state_changed(_element_index : int) -> void:
	undo_manager.register_diff()
