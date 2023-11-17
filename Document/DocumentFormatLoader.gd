class_name DocumentFormatLoader
extends ResourceFormatLoader

func _get_recognized_extensions():
	return PackedStringArray(["smtr"])

func _load(path: String, _original_path: String, use_sub_threads : bool, cache_mode : int):
	var file = FileAccess.open(path, FileAccess.READ)
	var resource = str_to_var(file.get_pascal_string())
	file.close()

	return resource
