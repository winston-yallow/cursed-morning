extends Control


@onready var vp: SubViewport = %SubViewport
@onready var composition: ColorRect = %Composition
@onready var shader: ShaderMaterial = composition.material

var _dream: Landscape


func _ready() -> void:
	vp.size = size
	resized.connect(
		func _on_size_changed():
			vp.size = size
	)
	shader = shader.duplicate()
	composition.material = shader
	shader.set_shader_parameter("vp", vp.get_texture())
	shader.set_shader_parameter("progress", 0.0)


func _input(event: InputEvent) -> void:
	vp.push_input(event)


func _unhandled_input(event: InputEvent) -> void:
	vp.push_unhandled_input(event)


func set_dream(dream: Node) -> void:
	_dream = dream
	vp.add_child(dream)


func _process(_delta: float) -> void:
	shader.set_shader_parameter("progress", _dream.sync_progress)
