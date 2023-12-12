extends StaticBody

var global = null

# Cached particles
onready var smoke : Particles = $Smoke

func _ready():
	if(!global): global = get_parent()

func _physics_process(_delta):
	smoke.process_material.direction = global.wind
	smoke.process_material.linear_accel = global.wind_strength * 100
	pass
