shader_type spatial;

// Controles en el inspector
uniform vec3 color_cinta : source_color = vec3(0.05, 0.05, 0.05); // Negro casi total
uniform vec2 velocidad = vec2(0.0, 1.5); // Velocidad del movimiento
uniform float cantidad_lineas = 20.0; // Cuántas líneas de textura se ven

void fragment() {
	// Desplazamos las coordenadas en base al tiempo
	vec2 uv_movida = UV + (TIME * velocidad);
	
	// Creamos un patrón de líneas usando una onda seno matemática basada en el movimiento
	float patron_lineas = step(0.5, sin(uv_movida.y * cantidad_lineas));
	
	// Mezclamos el color negro de la cinta con un tono gris oscuro usando las líneas artificiales
	vec3 color_final = mix(color_cinta, color_cinta * 2.5, patron_lineas);
	
	// Pasamos el color al motor
	ALBEDO = color_final;
	
	// Le damos un toque opaco y gastado (típico de goma de cinta vieja)
	ROUGHNESS = 0.7;
	SPECULAR = 0.2;
}