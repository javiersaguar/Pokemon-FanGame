shader_type canvas_item;
// Tinte del momento del día sobre el fondo, las capas y el frente: el «tone» de RGSS que usa
// Elite Battle: DX (daylightTint), que suma o resta a cada canal sin tocar el alfa.

uniform vec3 tone = vec3(0.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	COLOR = vec4(clamp(c.rgb + tone, 0.0, 1.0), c.a);
}
