@tool
extends EditorPlugin

var inspector_plugins : Array = [
	preload("./polygon_2d_inspector.gd").new()
]

func _enter_tree() -> void:
	print("inspector plugins enter tree")
	for inspector in inspector_plugins:
		add_inspector_plugin(inspector)

func _exit_tree() -> void:
	for inspector in inspector_plugins:
		remove_inspector_plugin(inspector)
