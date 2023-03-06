extends Spatial

const RAY_LENGTH = 200.0

onready var camera = $Camera
onready var mousecast = $MouseCast

# store data such as compass mode and wind
var mouse_pos : Vector3

# wind control
var wind : Vector3 = Vector3(1, 0, 0)
var wind_strength : float
# wind params
export var wind_rotational_velocity = 1
export var wind_strength_velocity = 2
export var wind_max = 10

# boat control
var is_compass_cardinal : bool
var compass_center : Vector3
var compass_dir : Vector3

func _ready():
	# in case camera is moved
	mousecast.set_translation(camera.get_translation())

func _process(_delta):
	get_mouse_pos()
	# check if compass is cardinal, if so save compass center
	if(Input.is_action_just_pressed("compass_cardinal")): 
		is_compass_cardinal = true
		compass_center = mouse_pos
	elif(Input.is_action_just_released("compass_cardinal")):
		is_compass_cardinal = false
	if(is_compass_cardinal): 
		compass_dir = (mouse_pos - compass_center)
		if(compass_dir != Vector3.ZERO): compass_dir /= compass_dir.length()
	else: $mousepoint.set_translation(mousecast.get_collision_point())
	# otherwise boats will just try to go towards the mouse
	
	# wind controls
	if(Input.is_action_pressed("wind_stronger")):
		wind_strength += wind_strength_velocity * _delta
	if(Input.is_action_pressed("wind_weaker")):
		wind_strength -= wind_strength_velocity * _delta
	# bounds check
	if(wind_strength < 0): wind_strength = 0
	elif(wind_strength > wind_max): wind_strength = wind_max
	
	if(Input.is_action_pressed("wind_clockwise")):
		wind = wind.rotated(Vector3.UP,  wind_rotational_velocity * _delta)
	if(Input.is_action_pressed("wind_counterclockwise")):
		wind = wind.rotated(Vector3.UP, -wind_rotational_velocity * _delta)

func get_mouse_pos():
	# get mouse position on water
	var mouse = get_viewport().get_mouse_position() # mouse position in viewport
	var raycast = camera.project_ray_normal(mouse) * RAY_LENGTH # vector from camera to mouse
	# raycast to hit water area
	mousecast.cast_to = raycast
	mousecast.force_raycast_update()
	if(mousecast.is_colliding()):
		mouse_pos = mousecast.get_collision_point()



