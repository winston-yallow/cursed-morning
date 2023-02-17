class_name DreamGenerator
extends RefCounted


signal finished(node: Node3D)

const FRONT = 0b10000
const LEFT = 0b01000
const RIGHT = 0b00100
const UP = 0b00010
const DOWN = 0b00001

var _allow_down := true
var _allow_up := true


class ChunkDefinition extends RefCounted:
	var exits := 0
	var packed_scene: PackedScene
	func _init(scn: PackedScene) -> void:
		var state := scn.get_state()
		for idx in state.get_node_property_count(0):
			var value = state.get_node_property_value(0, idx)
			if value is NodePath and not value.is_empty():
				match state.get_node_property_name(0, idx):
					"exit_front": exits |= FRONT
					"exit_left": exits |= LEFT
					"exit_right": exits |= RIGHT
					"exit_up": exits |= UP
					"exit_down": exits |= DOWN
		packed_scene = scn


var _chunk_defs: Array[ChunkDefinition] = [
	ChunkDefinition.new(preload("chunks/forward.tscn")),
	ChunkDefinition.new(preload("chunks/left.tscn")),
	ChunkDefinition.new(preload("chunks/right.tscn")),
	ChunkDefinition.new(preload("chunks/end.tscn")),
]


func run(directory: String) -> Node3D:
	_chunk_defs.clear()
	var dir := DirAccess.open(directory)
	if dir:
		for f in dir.get_files():
			var scn := load(directory.path_join(f))
			var def := ChunkDefinition.new(scn)
			_chunk_defs.append(def)
	else:
		push_error("Can't access chunk dir: '%s'" % directory)
	
	# Generate landscape
	var root := Marker3D.new()
	_allow_up = true
	_allow_down = true
	_add_trunk_to(root, 5)
	return root


func _add_trunk_to(root: Node3D, remaining: int) -> void:
	var start := Transform3D()
	var allow_left := true
	var allow_right := true
	
	while remaining > 0:
		
		# Create new chunk
		var mask := 0
		if remaining > 1:
			mask |= FRONT
			if allow_left: mask |= LEFT
			if allow_right: mask |= RIGHT
			if _allow_up: mask |= UP
			if _allow_down: mask |= DOWN
		var possible := get_matching_chunks(mask)
		var selected: PackedScene = possible.pick_random()
		var new: Chunk = selected.instantiate()
		root.add_child(new)
		new.transform = start
		remaining -= 1
		
		# Perform going up or down
		if new.exit_up:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_up, 0.0)
			_add_branch_to(root, start_next, true, remaining)
		if new.exit_down:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_down, 0.0)
			_add_branch_to(root, start_next, true, remaining)
		
		# Perform branching if we have a split chunk
		if new.exit_left:
			allow_left = false
			var start_next := get_end_transform(start, new.exit_left, TAU/4.0)
			_add_branch_to(root, start_next, true, remaining)
		if new.exit_right:
			allow_right = false
			var start_next := get_end_transform(start, new.exit_right, -TAU/4.0)
			_add_branch_to(root, start_next, true, remaining)
		
		# Adjust start transform, or break if it's an exit
		if new.exit_front:
			start = get_end_transform(start, new.exit_front)
		else:
			break


func _add_branch_to(root: Node3D, start: Transform3D, split_allowed: bool, remaining: int) -> void:
	while true:
		
		# Create new chunk
		var mask := 0
		if remaining > 1:
			mask |= FRONT
			if split_allowed: mask |= LEFT | RIGHT
			if _allow_up: mask |= UP
			if _allow_down: mask |= DOWN
		var possible := get_matching_chunks(mask)
		var selected: PackedScene = possible.pick_random()
		var new: Chunk = selected.instantiate()
		root.add_child(new)
		new.transform = start
		remaining -= 1
		
		# Perform going up or down
		if new.exit_up:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_up, 0.0)
			_add_branch_to(root, start_next, true, remaining)
		if new.exit_down:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_down, 0.0)
			_add_branch_to(root, start_next, true, remaining)
		
		# Perform branching if we have a split chunk
		var branched := false
		if new.exit_left:
			var start_next := get_end_transform(start, new.exit_left, TAU/4.0)
			_add_branch_to(root, start_next, false, remaining)
			branched = true
		if new.exit_right:
			var start_next := get_end_transform(start, new.exit_right, -TAU/4.0)
			_add_branch_to(root, start_next, false, remaining)
			branched = true
		if branched:
			if new.exit_front:
				var start_next := get_end_transform(start, new.exit_front)
				_add_branch_to(root, start_next, false, remaining)
			break
		
		# No branching, but break if it's an exit or up/down
		# without continuation on this floor
		if new.exit_front:
			start = get_end_transform(start, new.exit_front)
		else:
			break


func get_end_transform(base: Transform3D, module: Module, phi := 0.0) -> Transform3D:
	# TODO: Fix this mess
	var end := get_chunk_local_endpoint(module)
	return base.translated_local(end).rotated_local(Vector3.UP, phi)


func get_chunk_local_endpoint(module: Module) -> Vector3:
	var end := module.get_end_point()
	var current: Node3D = module
	while current and not current is Chunk:
		end = current.transform * end
		current = current.get_parent()
	return end


func get_matching_chunks(allowed: int) -> Array[PackedScene]:
	var matching: Array[PackedScene] = []
	for def in _chunk_defs:
		if not bool(def.exits - (def.exits & allowed)):
			matching.append(def.packed_scene)
	return matching
