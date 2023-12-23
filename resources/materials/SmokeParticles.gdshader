shader_type particles;

const float TAU = 2.0 * 3.14159;
const float PI_OVER_2 = 3.14159 * 0.5;

// for calculating spawn direction
uniform float ring_radius = 0.7;
uniform float spread_multiplier = 0.25;
// for calculating movement direction
uniform vec3 wind_dir = vec3(0.0, 0.0, -1.0);
uniform float wind_strength = 1.0;
uniform float friction = 0.5;
uniform float init_vert = 5.0;
uniform float init_scale = 0.5;

// generates random numbers, found in Godot docs https://docs.godotengine.org/en/3.5/tutorials/performance/vertex_animation/controlling_thousands_of_fish.html
float rand_from_seed(in uint seed) 
{
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) 
{
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

float rand_float(int base, uint number, uint random_seed)
{
	uint seed = hash(number + uint(base) + random_seed);
	return rand_from_seed(seed);
}

vec3 rescaleVector(vec3 vec, float a)
{
	float len = length(vec);
	if (len <= 0.0001) return vec;
	
	return vec * ( (len + a) / len );
}

mat4 rescaleTransform(mat4 transform, float a)
{
	transform[0].xyz = rescaleVector(transform[0].xyz, a);
	transform[1].xyz = rescaleVector(transform[1].xyz, a);
	transform[2].xyz = rescaleVector(transform[2].xyz, a);
	return transform;
}

void vertex()
{
	if (RESTART) // Runs when particle is first spawned
	{
		// Set particle initial position
		float angle = rand_float(1, NUMBER, RANDOM_SEED) * TAU;
		float dist = rand_float(27, NUMBER, RANDOM_SEED) * ring_radius;
		
		vec3 position = vec3(cos(angle) * dist, 0, sin(angle) * dist);
		
		TRANSFORM[3].xyz = position;
		VELOCITY.x = position.x * spread_multiplier;
		VELOCITY.z = position.z * spread_multiplier;
		VELOCITY.y = init_vert + rand_float(30, NUMBER, RANDOM_SEED) * spread_multiplier;
		
		// Set random rotation
		float x_angle = rand_float(44, NUMBER, RANDOM_SEED) * TAU;
		TRANSFORM[0].xyz = vec3(cos(x_angle), 0, sin(x_angle));
		TRANSFORM[2].xyz = vec3(cos(x_angle + PI_OVER_2), 0, sin(x_angle + PI_OVER_2));
		CUSTOM = vec4(0.5 + 0.5 * rand_float(45, NUMBER, RANDOM_SEED));
		
		// Initial scale
		TRANSFORM[0] *= init_scale;
		TRANSFORM[1] *= init_scale;
		TRANSFORM[2] *= init_scale;
		
		CUSTOM.w = 0.90;
	}
	
	VELOCITY.x += wind_dir.x * wind_strength * DELTA;
	VELOCITY.z += wind_dir.z * wind_strength * DELTA;
	if (VELOCITY.y > 0.0) VELOCITY.y -= DELTA * friction;
	
	// Rescale smoke to slowly grow and shrink
	float scale = sin((TIME + float(INDEX)) * 1.5) * 0.2 + 0.025;
	scale *= DELTA;
	
	TRANSFORM = rescaleTransform(TRANSFORM, scale);
	
	// Set transparency
	if (CUSTOM.w > 0.0) CUSTOM.w -= DELTA / LIFETIME;
}