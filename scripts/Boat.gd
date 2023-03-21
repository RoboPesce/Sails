extends KinematicBody

# PARAMS
export var max_velocity : float = 5
# minimum forward velocity, to keep boats from moving backwards
export var min_velocity : float = 0.1
# friction applied to forward velocity
export var friction : float = 0.05
# max rotational velocity, in radians
export var max_rot_velocity : float = .5
# fixed torque distance for horizontal wind force (also roughly corresponds to friction/decay)
export var torque_dist : float = .5
# max sail rotation speed
export var sail_angular_speed : float = .5
# otherwise, how fast the sail turns towards its target
export var sail_angular_lerp : float = .9

# References
# set on init
var global=null
# allows rotation of sail mesh
onready var sail_pivot : Spatial = $HullMesh/SailPivot
# keeps track of rotation of sail
onready var sail_dir : Spatial = $SailDir

# velocity is stored as a float and always applied forward
var velocity : float = max_velocity
# rotational velocity, in radians
var rot_velocity : float = 0

var sinking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# for debugging!!!!
	if(!global): global = get_parent()
	$AnimationPlayer.play("bob")

func init(_global):
	global = _global
	# set initial velocity?
	# set initial rotation?
	
func _physics_process(_delta):
	if sinking: return
	# find intended travel direction
	var dir = get_dir()
	# turn sail
	var rotation = get_sail_rotation_needed(dir) * _delta
	turn_sail(rotation)
	# get force
	var force = get_sail_force()
	# apply force to velocity and rotation
	apply_sail_force(force, _delta)
	
	turn_and_move(_delta)

# get the (normalized) direction the boat is commanded to go in
func get_dir() -> Vector3:
	# if(!global): return Vector3.ZERO
	var dir : Vector3
	if(global.is_compass_cardinal):
		dir = global.compass_dir #normalized by default
	else:
		dir = global.mouse_pos - transform.origin
		dir.y = 0
		if(dir != Vector3.ZERO): dir /= dir.length()
	return dir

# gets the rotation needed of the sail in radians towards dir
func get_sail_rotation_needed(dir : Vector3) -> float:
	if(dir == Vector3.ZERO): return 0.0
	# make dir local
	dir = transform.xform(dir)
	$dir_indicator_debug.rotate_y((-$dir_indicator_debug.transform.basis.z).signed_angle_to(dir, Vector3.UP)) # Debug

	# get angle between sail and dir
	var rads = (-sail_dir.transform.basis.z).signed_angle_to(dir, Vector3.UP)
	print("angle: ", rads) # debug
	# find proportion to travel
	rads = clamp(rads * sail_angular_lerp, -sail_angular_speed, sail_angular_speed)
	return rads

# turns the sail the given angle in rads
func turn_sail(ang) -> void:
	sail_dir.rotate_y(ang)
	sail_dir.transform = sail_dir.transform.orthonormalized() # (preserves shape from floating point errors)
	sail_pivot.rotate_y(ang)
	sail_pivot.transform = sail_pivot.transform.orthonormalized() # (preserves shape from floating point errors)

# calculates force by dotting the wind and sail direction vectors
# roughly, this is the flux of the wind through the sail
# this force is applied in the direction of sail_dir
func get_sail_force() -> Vector3:
	var wind_vec : Vector3 = transform.xform(global.wind * global.wind_strength)
	# this will be local
	var force = wind_vec.project(-sail_dir.transform.basis.z)
	return force

# z component of force becomes acceleration
# x component of force acts as a torque with fixed distance
func apply_sail_force(force : Vector3, delta : float) -> void:
	# print(force.normalized(), " ", force.length()) # debug
	velocity = clamp(velocity + force.z - friction * delta, min_velocity, max_velocity)
	if(force.z < 0): force.x *= -1
	rot_velocity = clamp(force.x * torque_dist, -max_rot_velocity, max_rot_velocity)
	
	$force_indicator_debug.rotate_y((-$force_indicator_debug.transform.basis.z).signed_angle_to(force, Vector3.UP)) # Debug

func turn_and_move(_delta):
	$windicator_debug.rotate_y((-$windicator_debug.transform.basis.z).signed_angle_to(transform.xform(global.wind), Vector3.UP)) # Debug
	$sail_indicator_debug.rotate_y((-$sail_indicator_debug.transform.basis.z).signed_angle_to(sail_dir.transform.basis.z, Vector3.UP)) # Debug
#	print("velocity is ", velocity)
	# turn the boat
#	rotate_y(rot_velocity * _delta)
#	transform = transform.orthonormalized() # (preserves shape from floating point errors)

	# move the boat and handle collisions
#	var collision = move_and_collide(transform.basis.z * velocity * _delta)
#	if(collision):
#		print()
#		if(collision.collider.get_collision_layer_bit(1)): # is a boat
#			sink()
#			collision.sink()
#		elif(collision.collider.get_collision_layer_bit(0)): # is the island
#			pass

# sinks the boat by removing the collider, then sliding downward
# until it disappears, then queue_freeing
func sink():
	sinking = true
	$CollisionShape.queue_free()
	$AnimationPlayer.play("sink")
	var timer = Timer.new()
	timer.connect("timeout",self,"queue_free") 
	add_child(timer)
	timer.start(3)
