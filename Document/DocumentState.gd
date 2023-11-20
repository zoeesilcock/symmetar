class_name DocumentState
extends Resource

# Data
@export var elements = [] # : ElementState
@export var previous_elements = [] # : ElementState

# Diff
@export var diffs_applied = [] # : DocumentStateDiff
@export var diffs_undone = [] # : DocumentStateDiff

# Signals
signal elements_count_changed
