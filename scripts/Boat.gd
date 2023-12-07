extends KinematicBody

# PARAMS
export var max_velocity : float = 5
# minimum forward velocity, to keep boats from moving backwards
export var min_velocity : float = 0.1
# friction applied to forward velocity
export var friction : float = 1
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
var global = null
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
	if(!global): global = get_parent() # TEMP
	$AnimationPlayer.play("bob")

#func init(_global):
#	global = _global
#	# set initial velocity?
#	# set initial rotation?
	
func _physics_process(_delta):
	if sinking: return
	turn_sail(_delta)
	apply_sail_force(_delta)
	turn_and_move(_delta)

# get the (normalized) direction the boat is commanded to go in
func get_dir_to_mouse() -> Vector3:
	# if(!global): return Vector3.ZERO
	var dir : Vector3
	if(global.is_compass_cardinal):
		dir = global.compass_dir # normalized by default
	else:
		dir = global.mouse_pos - transform.origin
		dir.y = 0
		if(dir != Vector3.ZERO): dir = dir.normalized()
	return -dir

func turn_sail(delta : float) -> void:
	# find intended travel direction
	var mouse_dir : Vector3 = get_dir_to_mouse()
	var ang : float
	if (mouse_dir == Vector3.ZERO): ang = 0.0
	else:
		# make dir local
		var oldmouse_dir = mouse_dir # DEBUG
		mouse_dir = transform.basis.xform_inv(mouse_dir)
		
		mouse_dir.y = $dir_indicator_debug.transform.origin.y # DEBUG
		$dir_indicator_debug.transform = $dir_indicator_debug.transform.looking_at(mouse_dir, Vector3.UP) # DEBUG
		#if (Time.get_ticks_usec()%10 < 2): print(-$dir_indicator_debug/pointer.transform.basis.z) # DEBUG
		mouse_dir.y = 0 # DEBUG
		if (Time.get_ticks_usec()%10 < 2): print(oldmouse_dir, " => ", mouse_dir) # DEBUG

		# get angle between sail and mouse_dir
		mouse_dir.y = sail_dir.transform.origin.y
		ang = (-sail_dir.transform.basis.z).signed_angle_to(mouse_dir, Vector3.UP)
		# find proportion to travel
		ang = clamp(ang * sail_angular_lerp, -sail_angular_speed, sail_angular_speed) * delta
	
	sail_dir.rotate_y(ang)
	sail_dir.transform = sail_dir.transform.orthonormalized() # (preserves shape from floating point errors)
	sail_pivot.rotate_y(ang)
	sail_pivot.transform = sail_pivot.transform.orthonormalized() # (preserves shape from floating point errors)
	
	$sail_indicator_debug.rotate_y(($sail_indicator_debug.transform.basis.z).signed_angle_to(sail_dir.transform.basis.z, Vector3.UP)) # DEBUG

# calculates force by dotting the wind and sail direction vectors
# roughly, this is the flux of the wind through the sail
# this force is applied in the direction of sail_dir
func get_sail_force() -> Vector3:
	$windicator_debug.rotate_y((-$windicator_debug.transform.basis.z).signed_angle_to(transform.xform(global.wind), Vector3.UP)) # DEBUG
	var wind_vec : Vector3 = transform.xform_inv(global.wind * global.wind_strength)
	# this will be local
	var force = wind_vec.project(sail_dir.transform.basis.z)
	return force

func apply_sail_force(delta : float) -> void:
	# get force, modify components if negative
	var force = get_sail_force()
	if (force.z < 0): 
		force.z = 0
		force.x *= -1
	# if (Time.get_ticks_usec()%10 < 5): print(force.normalized(), " ", force.length(), " | accel: ", force.z) # DEBUG
	velocity = clamp(velocity + force.z - friction * delta, min_velocity, max_velocity)
	rot_velocity = clamp(force.x * torque_dist, -max_rot_velocity, max_rot_velocity)
	
	$force_indicator_debug.rotate_y((-$force_indicator_debug.transform.basis.z).signed_angle_to(force, Vector3.UP)) # DEBUG
	$force_indicator_debug/force_pos.transform.origin = $force_indicator_debug.transform.xform_inv(15*force) # DEBUG

func turn_and_move(_delta):
	#if (Time.get_ticks_usec()%10 < 2): print("velocity is ", velocity) # DEBUG
	# turn the boat
	#rotate_y(.3 * _delta)
	transform = transform.orthonormalized() # (preserves shape from floating point errors)

#	# move the boat and handle collisions
#	var collision = move_and_collide(transform.basis.z * velocity * _delta)
#	if(collision):
#		print("collided")
#		if(collision.collider.get_collision_layer_bit(1)): # is a boat
#			sink()
#			collision.sink()
#		elif(collision.collider.get_collision_layer_bit(0)): # is the island
#			print("landed on island")

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
