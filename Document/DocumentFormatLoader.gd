class_name DocumentFormatLoader
extends ResourceFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["smtr"])

func _load(path: String, _original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var resource: DocumentState = str_to_var(file.get_pascal_string())
	file.close()

	return resource
