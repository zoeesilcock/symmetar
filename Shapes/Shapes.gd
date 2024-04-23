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
	HALF_CIRCLE,
	QUARTER_CIRCLE,
	LENS,
	CRESCENT,
	DIAMOND,
	PARALLELOGRAM,
	TEAR_DROP,
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
@export var half_circle: ShapeInfo
@export var quarter_circle: ShapeInfo
@export var lens: ShapeInfo
@export var crescent: ShapeInfo
@export var diamond: ShapeInfo
@export var parallelogram: ShapeInfo
@export var tear_drop: ShapeInfo

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
		ShapeIndex.HALF_CIRCLE: return half_circle
		ShapeIndex.QUARTER_CIRCLE: return quarter_circle
		ShapeIndex.LENS: return lens
		ShapeIndex.CRESCENT: return crescent
		ShapeIndex.DIAMOND: return diamond
		ShapeIndex.PARALLELOGRAM: return parallelogram
		ShapeIndex.TEAR_DROP: return tear_drop
		_: return trigon

