shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX = VERTEX*vec3(4.0, 1.5, 4.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0);
	ALPHA  = 10000000.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
