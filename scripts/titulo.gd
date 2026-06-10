extends Label

# Variables para regular los tiempos (en segundos)
var tiempo_espera : float = 0.0
var estado_encendido : bool = true

func _process(delta):
	# Restamos el tiempo que pasó en este frame
	tiempo_espera -= delta
	
	# Si el temporizador llegó a cero, cambiamos de estado
	if tiempo_espera <= 0.0:
		if estado_encendido:
			# --- SE APAGA ---
			visible = false
			estado_encendido = false
			# Elegimos cuánto tiempo va a durar apagado (entre 1.0 y 2.5 segundos)
			tiempo_espera = randf_range(1.0, 2.5) 
		else:
			# --- SE ENCIENDE ---
			visible = true
			estado_encendido = true
			# Elegimos cuánto tiempo va a durar encendido antes de volver a fallar
			# Le damos un tiempo largo (entre 3 y 6 segundos) para que se note el cartel andando
			tiempo_espera = randf_range(3.0, 6.0)

	# --- EFECTO EXTRA: El micro-parpadeo rápido ---
	# Incluso cuando está encendido, un cartel de neón viejo parpadea un milisegundo de vez en cuando
	if estado_encendido:
		if randf() > 0.99:
			visible = false
		else:
			visible = true
