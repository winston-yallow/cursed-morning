class_name ModulePath
extends Module


const SPEED := 5.0

@export_node_path("Module") var next_module: NodePath

@export_node_path("Path3D") var path_node: NodePath = "Path3D"
@onready var _curve: Curve3D = get_node(path_node).curve


func _ready() -> void:
	super()
	if has_node(next_module):
		next = get_node(next_module)


func _process(delta: float) -> void:
	character.anim.play("Run")
	character.rotation_degrees.y = 180.0
	# Advance time and offset
	time += delta
	var offset := time * SPEED
	progress = offset / _curve.get_baked_length()
	
	# Calculate new positions
	var capped_offset := min(offset, _curve.get_baked_length())
	var before := to_global(_curve.sample_baked(capped_offset - 0.1))
	var after := to_global(_curve.sample_baked(capped_offset + 0.1))
	var dir := before.direction_to(after)
	var dir_2d := Vector2(dir.x, dir.z)
	character.rotation.y = -dir_2d.angle() + TAU * 0.25
	character.position = to_global(_curve.sample_baked(offset))
	# TODO: Paths for camera positon too?
	camera_position.position = character.position + Vector3.UP * 1.5 + Vector3.BACK * 2.3
	camera_target.position = character.position + Vector3.UP * 1.0
	
	# Switch to next module if we reached the end
	if offset >= _curve.get_baked_length():
		# TODO: Calculate leftover time
		var distance_desired := delta * SPEED
		var distance_unreached := offset - _curve.get_baked_length()
		var ratio := distance_unreached / distance_desired
		switch_to_next(delta * ratio)
