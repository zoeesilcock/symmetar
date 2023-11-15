class_name World
extends Node2D

# References
@export var element_scene : PackedScene
@export var elements_node : Node2D

# Internal
var elements

func _ready():
	elements = []

func add_new_element():
	var new_element = element_scene.instantiate()

	elements_node.add_child(new_element)
	elements.push_front(new_element)

	new_element.init(len(elements))

func clear_elements():
	for element in elements:
		elements_node.remove_child(element)

	elements = []
