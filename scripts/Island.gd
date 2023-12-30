extends StaticBody

# Cached particles
onready var smoke_shader : ShaderMaterial = $Smoke.process_material
onready var volcano_attack : Spatial = $VolcanoAttack

func _physics_process(_delta):
	smoke_shader.set_shader_param("wind_dir", Global.wind)
	smoke_shader.set_shader_param("wind_strength", Global.wind_strength)
