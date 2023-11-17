class_name DocumentFormatSaver
extends ResourceFormatSaver

func _get_recognized_extensions(resource : Resource):
	return PackedStringArray(["smtr"])

func _recognize(resource : Resource):
	return resource is DocumentState

func _save(resource : Resource, path : String, flags : int):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_pascal_string(var_to_str(resource))
	file.close()

	return OK
