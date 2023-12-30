extends StaticBody

# Cached particles
onready var smokeShader : ShaderMaterial = $Smoke.process_material

func _physics_process(_delta):
	smokeShader.set_shader_param("wind_dir", Global.wind)
	smokeShader.set_shader_param("wind_strength", Global.wind_strength)
