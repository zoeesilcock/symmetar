extends Node
## Fixes semi-transparent popups after upgrading to Godot 4.6.

func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)

func _ready() -> void:
	_fix_windows_recursive(get_tree().root)

func _fix_windows_recursive(node: Node) -> void:
	if node is Window:
		node.transparent = false
		node.transparent_bg = false
	for child in node.get_children():
		_fix_windows_recursive(child)

func _on_node_added(node: Node) -> void:
	if node is Window:
		node.transparent = false
		node.transparent_bg = false
