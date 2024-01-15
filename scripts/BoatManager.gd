extends Spatial

onready var BoatScene = preload("res://scenes/Boat.tscn")

func _ready():
	spawn_boat();

func spawn_boat():
	var new_boat = BoatScene.instance()
	# todo: set position
	new_boat.transform.origin = Vector3(25.0, 0.0, 0.0)
	add_child(new_boat)
