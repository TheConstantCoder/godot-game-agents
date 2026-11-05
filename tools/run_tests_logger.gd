extends Logger
## Collects engine and script errors for tools/run_tests.gd (Godot 4.5+, where Logger exists).
## Loaded only when ClassDB has Logger, so older Godot versions never parse this file.

var _errors: PackedStringArray = PackedStringArray()
var _mutex: Mutex = Mutex.new()


func _log_error(function: String, file: String, line: int, code: String, rationale: String,
		_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == ERROR_TYPE_WARNING:
		return
	_mutex.lock()
	_errors.append("%s (%s:%d %s) %s" % [code, file.get_file(), line, function, rationale])
	_mutex.unlock()


func take() -> PackedStringArray:
	_mutex.lock()
	var out: PackedStringArray = _errors.duplicate()
	_errors.clear()
	_mutex.unlock()
	return out
