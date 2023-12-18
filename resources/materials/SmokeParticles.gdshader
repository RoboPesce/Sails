shader_type particles;

// for calculating spawn direction
uniform float ring_radius = 2.0;
// for calculating movement direction
uniform vec3 wind_dir = vec3(0.0, 0.0, -1.0);
uniform float wind_strength = 1.0;
const float friction = 0.5;
const float init_vert = 5.0;

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

void vertex()
{
	if(RESTART) // Runs when particle is first spawned
	{
		uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
		uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
		float angle = rand_from_seed(alt_seed1) * 2.0 * 3.14159;
		float dist = rand_from_seed(alt_seed2) * ring_radius;
		
		vec3 position = vec3
			(
				cos(angle) * dist,
                0,
                sin(angle) * dist
			);
	
		TRANSFORM[3].xyz = position;
		VELOCITY.y = init_vert;
	}
	
	VELOCITY.x += wind_dir.x * wind_strength * DELTA;
	VELOCITY.z += wind_dir.z * wind_strength * DELTA;
	VELOCITY.y -= DELTA * friction;
	if (VELOCITY.y < 0.0) VELOCITY.y = 0.0;
}