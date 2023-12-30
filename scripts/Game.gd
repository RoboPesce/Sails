extends Spatial

const RAY_LENGTH = 2000.0

onready var camera = $MainCamera
onready var mousecast = $MouseCast


func _ready():
	# in case camera is moved
	mousecast.set_translation(camera.get_translation())
	
func _process(_delta):
	cache_mouse_pos()
	# wind controls
	if(Input.is_action_pressed("wind_stronger")):
		Global.wind_strength += Global.wind_strength_velocity * _delta
	if(Input.is_action_pressed("wind_weaker")):
		Global.wind_strength -= Global.wind_strength_velocity * _delta
	# bounds check
	Global.wind_strength = clamp(Global.wind_strength, Global.wind_min, Global.wind_max)
	
	if(Input.is_action_pressed("wind_counterclockwise")):
		Global.wind = Global.wind.rotated(Vector3.UP,  Global.wind_rotational_velocity * _delta)
	if(Input.is_action_pressed("wind_clockwise")):
		Global.wind = Global.wind.rotated(Vector3.UP, -Global.wind_rotational_velocity * _delta)

func cache_mouse_pos() -> void:
	# get mouse position on water
	var mouse = get_viewport().get_mouse_position() # mouse position in viewport
	var raycast = camera.project_ray_normal(mouse) * RAY_LENGTH # vector from camera to mouse
	# raycast to hit water area
	mousecast.cast_to = raycast
	mousecast.force_raycast_update()
	if(mousecast.is_colliding()):
		Global.mouse_pos = mousecast.get_collision_point()
