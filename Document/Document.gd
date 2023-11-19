class_name Document
extends Node2D

# References
@export var state : DocumentState
@export var element_scene : PackedScene
@export var elements_node : Node2D

# Internal
var elements

func _ready():
	elements = []

	state = DocumentState.new()

func load_document(path : String):
	clear_elements()
	state = ResourceLoader.load(path)
	_instantiate_elements()

func save_document(path : String):
	ResourceSaver.save(state, path)

func get_element_state(index : int) -> ElementState:
	return state.elements[index]

func add_new_element():
	var new_element = element_scene.instantiate()
	var element_index = len(elements)

	elements_node.add_child(new_element)
	elements.push_back(new_element)

	var element_state = ElementState.new()
	element_state.index = element_index
	element_state.slice_count = 8
	element_state.radius = 200
	element_state.slice_position = Vector2(element_state.radius, 0)

	state.elements.push_back(element_state)
	new_element.init(element_state)

func clear_elements():
	for element in elements:
		elements_node.remove_child(element)

	elements = []

func _instantiate_elements():
	elements.resize(len(state.elements))

	for element_index in len(state.elements):
		var loaded_element = element_scene.instantiate()
		elements_node.add_child(loaded_element)
		elements[element_index] = loaded_element

		loaded_element.init(state.elements[element_index])
