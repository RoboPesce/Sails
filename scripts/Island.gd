extends StaticBody

var global = null

# Cached particles
onready var smokeShader : Particles = $Smoke.process_material

func _ready():
	if(!global): global = get_parent()

func _physics_process(_delta):
	smokeShader.set_shader_param("wind_dir", global.wind)
