class_name ModulePath
extends Module


const SPEED := 5.0
const CAMERA_POSITION := Vector3.UP * 1.7 + Vector3.FORWARD * 1.7
const CAMERA_TARGET := Vector3.UP * 1.3

@export_node_path("Module") var next_module: NodePath

@export_node_path("Path3D") var path_node: NodePath = "Path3D"
@onready var _path: Path3D = get_node(path_node)
@onready var _curve: Curve3D = _path.curve


func _ready() -> void:
	super()
	if has_node(next_module):
		next = get_node(next_module)


func _process(delta: float) -> void:
	character.anim.play("Run")
	
	# Advance time and offset
	time += delta
	var offset := time * SPEED
	progress = offset / _curve.get_baked_length()
	
	# Calculate new positions
	var capped_offset: float = min(offset, _curve.get_baked_length())
	var before := _path.to_global(_curve.sample_baked(capped_offset - 0.1))
	var after := _path.to_global(_curve.sample_baked(capped_offset + 0.1))
	var dir := before.direction_to(after)
	var dir_2d := Vector2(dir.x, dir.z)
	character.rotation.y = -dir_2d.angle() + TAU * 0.25
	character.position = _path.to_global(_curve.sample_baked(offset))
	# TODO: Paths for camera positon too?
	# Calculate camera positons relative to character
	camera_position.position = character.to_global(CAMERA_POSITION)
	camera_target.position = character.to_global(CAMERA_TARGET)
	
	# Switch to next module if we reached the end
	if offset >= _curve.get_baked_length():
		# TODO: Calculate leftover time
		var distance_desired := delta * SPEED
		var distance_unreached := offset - _curve.get_baked_length()
		var ratio := distance_unreached / distance_desired
		switch_to_next(delta * ratio)


func get_end_point() -> Vector3:
	# Not using _path since we want this method to work before _ready
	var path: Path3D = get_node(path_node)
	var curve: Curve3D = path.curve
	return path.transform * curve.get_baked_points()[curve.get_baked_points().size() - 1]
