shader_type canvas_item;
// "Bush depth" de Essentials: la parte de abajo del cuadro del personaje se ve
// medio transparente cuando está en hierba alta. No dibuja nada nuevo: solo
// cambia la opacidad de los píxeles de la hoja.

uniform float cut = 0.8;      // fracción del cuadro a partir de la cual se aclara
uniform float vframes = 4.0;  // filas de la hoja (para saber la posición dentro del cuadro)
uniform float opacity = 0.45;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float in_frame = fract(UV.y * vframes);
	if (in_frame >= cut) {
		color.a *= opacity;
	}
	COLOR = color;
}
