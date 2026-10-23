// Carta deitada no tampo: cada vértice passa pela mesma perspectiva da mesa (mesa.gd proj(), homografia).
// A carta chega posicionada em proj(P) com escala uniforme; aqui o deslocamento de cada vértice volta para o
// projeto da mesa (com o escorço na altura) e é projetado de novo: afina para o fundo, encurta e inclina junto
// com o espaço entalhado. plano 0 = reta (mão, segurada, no ar) · 1 = deitada. Coordenadas do mundo da mesa.
uniform float plano = 0.0;
uniform float cx = 180.0;
uniform float base_y = 606.0;
uniform float k = 0.0;
uniform float a = 1.0;
uniform float escorco = 0.85;

vec2 projetar(vec2 d) {
	float u = base_y - d.y;
	float q = 1.0 + k * u;
	return vec2(cx + (d.x - cx) / q, base_y - a * u / q);
}

void vertex() {
	if (plano > 0.001) {
		vec2 w = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
		vec2 p = MODEL_MATRIX[3].xy;
		float h = base_y - p.y;
		float up = h / (a - k * h);
		float qp = 1.0 + k * up;
		vec2 dp = vec2(cx + (p.x - cx) * qp, base_y - up);          // centro da carta no projeto da mesa
		vec2 o = (w - p) * qp;
		o.y *= escorco;
		vec2 n = projetar(dp + o);
		VERTEX = (inverse(MODEL_MATRIX) * vec4(mix(w, n, plano), 0.0, 1.0)).xy;
	}
}
