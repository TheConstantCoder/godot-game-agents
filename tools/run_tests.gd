extends SceneTree
## Minimal headless test runner for Godot 4 (no addon needed).
##
##   godot --headless --path . --script res://tools/run_tests.gd -- [--only name1,name2] [--quiet]
##   godot --headless --path . --script res://tools/run_tests.gd -- --parse-only
##
## Finds every test_*.gd under TEST_ROOTS, calls its run(tree), and prints TESTS_OK only if no test
## reported a failure AND (on Godot 4.5+) no engine or script error was logged while it ran, so a
## crash inside a helper can never pass. Godot's exit code is not reliable; read the marker line.
##
## Test contract:
##   extends RefCounted
##   func run(tree: SceneTree) -> PackedStringArray   # failure messages; empty = pass. May await.
## A test that deliberately triggers engine errors lists their substrings in
##   const EXPECTED_ERRORS: PackedStringArray = ["..."]

const TEST_ROOTS: PackedStringArray = ["res://"]
const SKIP_DIRS: PackedStringArray = [".godot", ".git", "addons", ".claude"]
const COLLECTOR_PATH: String = "res://tools/run_tests_logger.gd"

var _collector: Object = null


func _initialize() -> void:
	# OS.add_logger() exists from Godot 4.5; on older versions the runner still works, but only the
	# failures a test returns are counted.
	if ClassDB.class_exists("Logger") and ResourceLoader.exists(COLLECTOR_PATH):
		_collector = (load(COLLECTOR_PATH) as GDScript).new()
		OS.call("add_logger", _collector)
	_run_all.call_deferred()


func _run_all() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var quiet: bool = args.has("--quiet")
	var only: PackedStringArray = PackedStringArray()
	var i: int = args.find("--only")
	if i >= 0 and i + 1 < args.size():
		only = args[i + 1].split(",", false)

	if args.has("--parse-only"):
		_parse_all()
		return

	var paths: PackedStringArray = PackedStringArray()
	for root: String in TEST_ROOTS:
		_find_scripts(root, true, paths)
	paths.sort()
	if not only.is_empty():
		var picked: PackedStringArray = PackedStringArray()
		for p: String in paths:
			if only.has(p.get_file().get_basename()):
				picked.append(p)
		paths = picked

	var failures: PackedStringArray = PackedStringArray()
	if paths.is_empty():
		failures.append("no test_*.gd files found" + ("" if only.is_empty() else " for --only " + ",".join(only)))
	for path: String in paths:
		_take_errors()
		var t0: int = Time.get_ticks_msec()
		var file_fails: PackedStringArray = await _run_one(path)
		for msg: String in file_fails:
			failures.append("%s: %s" % [path.get_file(), msg])
		if not file_fails.is_empty() or not quiet:
			print("[%s] %s  %d ms" % ["PASS" if file_fails.is_empty() else "FAIL", path, Time.get_ticks_msec() - t0])
			for msg: String in file_fails:
				print("  - ", msg)

	if failures.is_empty():
		print("TESTS_OK (%d files)" % paths.size())
		quit(0)
	else:
		print("TESTS_FAILED (%d failures)" % failures.size())
		quit(1)


func _run_one(path: String) -> PackedStringArray:
	var script: GDScript = load(path) as GDScript
	if script == null or not script.can_instantiate():
		return PackedStringArray(["could not load (parse error?)"])
	var test: Object = script.new()
	if not test.has_method("run"):
		return PackedStringArray(["has no run(tree) method"])
	var fails: PackedStringArray = PackedStringArray()
	var result: Variant = await test.call("run", self)
	if result is PackedStringArray:
		fails.append_array(result)
	elif result != null:
		fails.append("run() must return PackedStringArray, got %s" % type_string(typeof(result)))
	var expected: PackedStringArray = PackedStringArray()
	var consts: Dictionary = script.get_script_constant_map()
	if consts.has("EXPECTED_ERRORS"):
		expected = consts["EXPECTED_ERRORS"]
	for err: String in _take_errors():
		var allowed: bool = false
		for e: String in expected:
			if err.contains(e):
				allowed = true
				break
		if not allowed:
			fails.append("engine error: " + err)
	return fails


func _take_errors() -> PackedStringArray:
	if _collector == null:
		return PackedStringArray()
	return _collector.call("take")


## Loads every .gd file once, without running anything, and prints PARSE_OK or PARSE_FAILED.
## Works in a project with no main scene (booting the project to parse-check it does not).
func _parse_all() -> void:
	var paths: PackedStringArray = PackedStringArray()
	for root: String in TEST_ROOTS:
		_find_scripts(root, false, paths)
	paths.sort()
	var bad: PackedStringArray = PackedStringArray()
	for path: String in paths:
		_take_errors()
		var script: GDScript = load(path) as GDScript
		var errs: PackedStringArray = _take_errors()
		if script == null or not errs.is_empty():
			bad.append(path + ("" if errs.is_empty() else ": " + errs[0]))
	for line: String in bad:
		print("  - ", line)
	if bad.is_empty():
		print("PARSE_OK (%d scripts)" % paths.size())
		quit(0)
	else:
		print("PARSE_FAILED (%d scripts)" % bad.size())
		quit(1)


func _find_scripts(dir_path: String, tests_only: bool, out: PackedStringArray) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		if not SKIP_DIRS.has(sub):
			_find_scripts(dir_path.path_join(sub), tests_only, out)
	for file: String in dir.get_files():
		if file.ends_with(".gd") and (not tests_only or file.begins_with("test_")):
			out.append(dir_path.path_join(file))
