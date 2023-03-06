extends KinematicBody

# max sail rotation speed
export var sail_angular_speed = .5
export var sail_angular_lerp = .9

onready var sail_pivot = $HullMesh/SailPivot
# keeps track of local rotation of sail
# 3D vector with y component = 0
var sail_dir : Vector3 = Vector3(0, 0, 1)
# set on init
var global=null

# Called when the node enters the scene tree for the first time.
func _ready():
	# for debugging!!!!
	if(!global): global = get_parent()
	
func init(_global):
	global = _global
	
func _physics_process(_delta):
	# find intended travel direction
	var dir = get_dir()
	# turn sail
	var rotation = get_sail_rotation_needed(dir) * _delta
	turn_sail(rotation)
	# move and rotate boat
#	var force_2D = get_sail_force()
#	var force = Vector3(force_2D.x, 0, force_2D.y)
#	var forward = global_transform.basis.z
#	force *= forward.dot(force) * speed * _delta
#	move_and_collide(force)

# get the (normalized) direction the boat is commanded to go in
func get_dir() -> Vector3:
	# if(!global): return Vector3.ZERO
	var dir
	if(global.is_compass_cardinal):
		dir = global.compass_dir #normalized by default
	else:
		dir = global.mouse_pos - transform.origin
		dir.y = 0
		if(dir != Vector3.ZERO): dir /= dir.length()
	return dir

# gets the rotation needed of the sail in degrees towards dir
func get_sail_rotation_needed(dir : Vector3) -> float:
	if(dir == Vector3.ZERO): return 0.0
	# get angle between sail and dir
	var global_sail_dir = transform * sail_dir
	var rads = global_sail_dir.signed_angle_to(dir, Vector3.UP)
	# find proportion to travel
	rads *= sail_angular_lerp
	# bounds check
	if  (rads >  sail_angular_speed): rads =  sail_angular_speed
	elif(rads < -sail_angular_speed): rads = -sail_angular_speed
	return rads

# turns the sail the set angle in rads
func turn_sail(ang):
	sail_dir = sail_dir.rotated(Vector3.UP, ang)
	sail_pivot.rotate_y(ang)

# calculates force vector by dotting the wind and sail direction vectors
# roughly, this describes the flux of the wind through the sail
# this force will be applied in the direction of sail_dir
func get_sail_force():
	var wind_vec = global.wind * global.wind_strength
	return sail_dir * sail_dir.dot(wind_vec)
