shader_type canvas_item;
// Brillo que recorre las letras amarillas del logo de la portada (solo donde el píxel es
// amarillo: no toca el fondo). No dibuja nada nuevo: aclara los píxeles de la imagen.
void fragment() {
	float phase = fract(TIME * 0.16) * 1.6 - 0.3;
	float distance_to_band = abs(FRAGCOORD.x / 512.0 + FRAGCOORD.y / 1536.0 - phase);
	float shine = (1.0 - smoothstep(0.0, 0.045, distance_to_band)) * 0.6;
	float yellow = smoothstep(0.55, 0.75, COLOR.g) * step(COLOR.b, 0.45) * step(0.6, COLOR.r);
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), shine * yellow);
}
