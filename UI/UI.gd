class_name UI
extends CanvasLayer

# References
@export var world : World
@export var ui_state : UIState

# Signals
signal add_button_pressed
signal clear_button_pressed

func _ready():
	self.add_button_pressed.connect(self._on_add_button_pressed)
	self.clear_button_pressed.connect(self._on_clear_button_pressed)

func _on_add_button_pressed():
	world.add_new_element()

func _on_clear_button_pressed():
	world.clear_elements()
