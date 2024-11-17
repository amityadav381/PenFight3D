shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX = VERTEX*vec3(1.25, 1.20, 1.25);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0);
	ALPHA  = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
