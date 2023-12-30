extends Camera

export var noise_texture : Texture
var noise_data : Image

var index : Vector2 = Vector2.ZERO

export var wind_strength_multiplier : float = 0.05
export var wind_buffet_multiplier : float = 1.0

var starting_basis : Basis

func _ready():
	noise_data = noise_texture.get_data()
	noise_data.lock()
	
	starting_basis = transform.basis

func _physics_process(_delta):
	
	transform.basis = starting_basis
	
	# offset camera by the wind direction/strength
	var wind = Global.wind * Global.wind_strength * wind_strength_multiplier
	# add some noise to mimic the camera getting pushed around
	wind += wind * wind_buffet_multiplier * noise_data.get_pixelv(index).r * noise_data.get_pixelv(index).r
	
	transform.basis = transform.basis.rotated(transform.basis.y, -wind.x).rotated(transform.basis.x, -wind.z)
	
	index.x += 1
	if (index.x >= noise_data.get_width()): 
		index.x = 0
		index.y += 1
		if (index.y >= noise_data.get_height()): index.y = 0
