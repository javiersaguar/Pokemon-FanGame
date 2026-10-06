shader_type canvas_item;
// Barrido sobre coordenadas de pantalla: no deforma ni filtra los glifos.
void fragment() {
	float phase = fract(TIME * 0.18);
	float distance_to_band = abs(FRAGCOORD.x / 512.0 - phase);
	float shine = (1.0 - smoothstep(0.0, 0.05, distance_to_band)) * 0.45;
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), shine);
}
