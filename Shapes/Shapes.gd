class_name Shapes
extends Resource

enum ShapeIndex {
	TRIGON,
	TETRAGON,
	PENTAGON,
	HEXAGON,
	HEPTAGON,
	OCTAGON,
	ENNEAGON,
	DODECAGON,
	CIRCLE,
}

# Data
@export var trigon: ShapeInfo
@export var tetragon: ShapeInfo
@export var pentagon: ShapeInfo
@export var hexagon: ShapeInfo
@export var heptagon: ShapeInfo
@export var octagon: ShapeInfo
@export var enneagon: ShapeInfo
@export var dodecagon: ShapeInfo
@export var circle: ShapeInfo

func get_shape_info(shape_index: ShapeIndex) -> ShapeInfo:
	match (shape_index):
		ShapeIndex.TETRAGON: return tetragon
		ShapeIndex.PENTAGON: return pentagon
		ShapeIndex.HEXAGON: return hexagon
		ShapeIndex.HEPTAGON: return heptagon
		ShapeIndex.OCTAGON: return octagon
		ShapeIndex.HEPTAGON: return heptagon
		ShapeIndex.ENNEAGON: return enneagon
		ShapeIndex.DODECAGON: return dodecagon
		ShapeIndex.CIRCLE: return circle
		_: return trigon
