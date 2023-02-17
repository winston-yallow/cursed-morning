class_name DreamGenerator
extends RefCounted


signal finished(node: Landscape)

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


var _chunk_defs: Array[ChunkDefinition] = []


func run(sync_module: Module) -> Landscape:
	# Pick start chunk
	var start_directory := "res://src/dreams/chunks_starters"
	var start_dir := DirAccess.open(start_directory)
	var possible: Array[PackedScene] = []
	if start_dir:
		for f in start_dir.get_files():
			var scn := load(start_directory.path_join(f))
			var path := get_first_module_filepath(scn)
			if path == sync_module.scene_file_path:
				possible.append(scn)
	else:
		push_error("Can't access chunk dir: '%s'" % start_directory)
	var start: ChunkStart = possible.pick_random().instantiate()
	
	# Generate chunk definitions
	_chunk_defs.clear()
	var theme: String = start.themes.pick_random()
	var proc_directory := "res://src/dreams/chunks_procedural".path_join(theme)
	var proc_dir := DirAccess.open(proc_directory)
	if proc_dir:
		for f in proc_dir.get_files():
			var scn := load(proc_directory.path_join(f))
			var def := ChunkDefinition.new(scn)
			_chunk_defs.append(def)
	else:
		push_error("Can't access chunk dir: '%s'" % proc_directory)
	
	# Generate landscape
	var root := Landscape.new()
	_allow_up = true
	_allow_down = true
	_add_trunk_to(root, start, 5)
	
	var character := preload("res://src/character/punk.tscn").instantiate()
	root.add_child(character)
	root.character = character
	
	var cam_position := Marker3D.new()
	root.add_child(cam_position)
	root.camera_position = cam_position
	
	var cam_target := Marker3D.new()
	root.add_child(cam_target)
	root.camera_target = cam_target
	
	var cam := SmoothCamera.new()
	root.add_child(cam)
	root.camera = cam
	cam.target_from = cam_position
	cam.target_to = cam_target
	
	root.first_module = root.get_child(0).first_module
	
	return root


func _add_trunk_to(root: Landscape, first: Chunk, remaining: int) -> void:
	var start := Transform3D()
	var allow_left := true
	var allow_right := true
	var last: Module
	
	while remaining > 0:
		
		# Create new chunk
		var new: Chunk
		if is_instance_valid(first):
			new = first
			first = null
		else:
			var mask := 0
			if remaining > 1:
				mask |= FRONT
				if allow_left: mask |= LEFT
				if allow_right: mask |= RIGHT
				if _allow_up: mask |= UP
				if _allow_down: mask |= DOWN
			var possible := get_matching_chunks(mask)
			var selected: PackedScene = possible.pick_random()
			new = selected.instantiate()
		if is_instance_valid(last):
			last.next = new.first_module
		root.add_child(new)
		new.transform = start
		remaining -= 1
		
		# Perform going up or down
		if new.exit_up:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_up, 0.0)
			_add_branch_to(root, new.exit_up, start_next, true, remaining)
		if new.exit_down:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_down, 0.0)
			_add_branch_to(root, new.exit_down, start_next, true, remaining)
		
		# Perform branching if we have a split chunk
		if new.exit_left:
			allow_left = false
			var start_next := get_end_transform(start, new.exit_left, TAU/4.0)
			_add_branch_to(root, new.exit_left, start_next, true, remaining)
		if new.exit_right:
			allow_right = false
			var start_next := get_end_transform(start, new.exit_right, -TAU/4.0)
			_add_branch_to(root, new.exit_right, start_next, true, remaining)
		
		# Adjust start transform, or break if it's an exit
		if new.exit_front:
			start = get_end_transform(start, new.exit_front)
			last = new.exit_front
		else:
			break


func _add_branch_to(root: Landscape, last: Module, start: Transform3D, split_allowed: bool, remaining: int) -> void:
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
		last.next = new.first_module
		root.add_child(new)
		new.transform = start
		remaining -= 1
		
		# Perform going up or down
		if new.exit_up:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_up, 0.0)
			_add_branch_to(root, new.exit_up, start_next, true, remaining)
		if new.exit_down:
			_allow_up = false
			var start_next := get_end_transform(start, new.exit_down, 0.0)
			_add_branch_to(root, new.exit_down, start_next, true, remaining)
		
		# Perform branching if we have a split chunk
		var branched := false
		if new.exit_left:
			var start_next := get_end_transform(start, new.exit_left, TAU/4.0)
			_add_branch_to(root, new.exit_left, start_next, false, remaining)
			branched = true
		if new.exit_right:
			var start_next := get_end_transform(start, new.exit_right, -TAU/4.0)
			_add_branch_to(root, new.exit_right, start_next, false, remaining)
			branched = true
		if branched:
			if new.exit_front:
				var start_next := get_end_transform(start, new.exit_front)
				_add_branch_to(root, new.exit_front, start_next, false, remaining)
			break
		
		# No branching, but break if it's an exit or up/down
		# without continuation on this floor
		if new.exit_front:
			start = get_end_transform(start, new.exit_front)
			last = new.exit_front
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


func get_first_module_filepath(scn: PackedScene) -> String:
	var state := scn.get_state()
	var path: NodePath
	for prop_idx in state.get_node_property_count(0):
		if state.get_node_property_name(0, prop_idx) == "first_module":
			path = state.get_node_property_value(0, prop_idx)
	path = NodePath("./" + str(path))
	for idx in state.get_node_count():
		if state.get_node_path(idx) == path:
			return state.get_node_instance(idx).resource_path
	return ""
