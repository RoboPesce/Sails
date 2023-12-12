extends StaticBody

var global : Global = null

# Cached particles
onready var smoke : Particles = $Smoke

func _ready():
	if(!global): global = get_parent()

func _physics_process(delta):
	smoke.process_material.direction = global.wind
	smoke.process.material.linear_accel = global.wind_strength
	pass
