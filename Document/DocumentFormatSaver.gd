class_name DocumentFormatSaver
extends ResourceFormatSaver

func _get_recognized_extensions(_resource : Resource) -> PackedStringArray:
	return PackedStringArray(["smtr"])

func _recognize(resource : Resource) -> bool:
	return resource is DocumentState

func _save(resource : Resource, path : String, _flags : int) -> Error:
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_pascal_string(var_to_str(resource as DocumentState))
	file.close()

	return OK
