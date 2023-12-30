extends Node

# wind control
var wind : Vector3 = Vector3.FORWARD
var wind_strength : float
# wind params
export var wind_rotational_velocity : float = .6
export var wind_strength_velocity : float = .2
export var wind_max : float = 1
export var wind_min : float = 0.2

# boat control
var mouse_pos : Vector3 = Vector3.ZERO

var is_compass_cardinal : bool
var compass_center : Vector3
var compass_dir : Vector3

func _ready():
	wind_strength = wind_min
	
func _process(_delta):
	# check if compass is cardinal, if so save compass center
	if(Input.is_action_just_pressed("compass_cardinal")): 
		is_compass_cardinal = true
		compass_center = mouse_pos
	elif(Input.is_action_just_released("compass_cardinal")):
		is_compass_cardinal = false
	if(is_compass_cardinal): 
		compass_dir = (mouse_pos - compass_center)
		if(compass_dir != Vector3.ZERO): compass_dir /= compass_dir.length()
