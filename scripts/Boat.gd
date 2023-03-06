extends KinematicBody

# max velocity
export var max_velocity = 5
# horizontal "friction" scalar to keep boat from drifting sideways
export var friction_x = .1
# minimum forward velocity, to keep boats from moving backwards
export var min_z = 0
# max sail rotation speed
export var sail_angular_speed = .5
export var sail_angular_lerp = .9

onready var sail_pivot = $HullMesh/SailPivot
# keeps track of local rotation of sail

var velocity : Vector3
# normalized vector with y component = 0, represents direction of sail
var sail_dir : Vector3 = Vector3.BACK
# set on init
var global=null

# Called when the node enters the scene tree for the first time.
func _ready():
	# for debugging!!!!
	if(!global): global = get_parent()
	
func init(_global):
	global = _global
	# set initial velocity?
	
func _physics_process(_delta):
	# find intended travel direction
	var dir = get_dir()
	# turn sail
	var rotation = get_sail_rotation_needed(dir) * _delta
	turn_sail(rotation)
	# get force
	var force = get_sail_force()
	# apply force to velocity
	velocity += force
	# get local version of velocity for friction/bounds
	var local_velocity = transform.xform_inv(velocity)
	local_velocity.x *= friction_x
	if(local_velocity.z < min_z): local_velocity.z = min_z
	velocity = transform.xform(local_velocity)
	var velocity_len = velocity.length()
	if(velocity_len > max_velocity): velocity = (max_velocity / velocity_len) * velocity
	# rotate the boat
	look_at(velocity + translation, Vector3.UP)
	# move the boat
	move_and_collide(velocity * _delta)

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
	var global_sail_dir = transform.xform(sail_dir)
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

# calculates force by dotting the wind and sail direction vectors
# roughly, this is the flux of the wind through the sail
# this force is applied in the direction of sail_dir
func get_sail_force() -> Vector3:
	# find its "true" strength
	var global_sail_dir = transform * sail_dir
	var wind_vec = global.wind * global.wind_strength
	# this will be global
	var force = wind_vec.project(global_sail_dir)
	return force
