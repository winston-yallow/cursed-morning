extends Control


@onready var vp: SubViewport = %SubViewport
@onready var composition: ColorRect = %Composition
@onready var shader: ShaderMaterial = composition.material


func _ready() -> void:
	# For some reason automatic updating does not work
	vp.size = size
	resized.connect(
		func _on_size_changed():
			vp.size = size
	)
	shader = shader.duplicate()
	composition.material = shader
	shader.set_shader_parameter("vp", vp.get_texture())
	shader.set_shader_parameter("progress", 1.0)
	
	# TODO: Remove this debug code
	var t := create_tween()
	t.tween_method(
		func fade_in(r):
			shader.set_shader_parameter("progress", r),
		0.0,
		1.0,
		1.0
	)


func set_dream(dream: Node) -> void:
	vp.add_child(dream)
