extends RefCounted
## Example test for tools/run_tests.gd. Copy it next to the code it tests and rename it.
## run() returns failure messages; an empty array is a pass. It may await frames on `tree`.


func run(tree: SceneTree) -> PackedStringArray:
	var fails: PackedStringArray = PackedStringArray()

	var numbers: Array[int] = [3, 1, 2]
	numbers.sort()
	if numbers != [1, 2, 3]:
		fails.append("sort: expected [1, 2, 3], got %s" % [numbers])

	# Nodes need the tree: add, wait a frame, check, and always free what you made.
	var node: Node = Node.new()
	tree.root.add_child(node)
	await tree.process_frame
	if not node.is_inside_tree():
		fails.append("node: not inside the tree after a frame")
	node.queue_free()
	await tree.process_frame

	return fails
