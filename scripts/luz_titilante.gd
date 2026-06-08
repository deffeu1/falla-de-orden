extends SpotLight3D 

@export var energia_maxima : float = 4.0
@export var energia_minima : float = 0.1

func _ready():
	# Arrancamos el ciclo de parpadeo
	esperar_y_titilar()

func esperar_y_titilar():
	while true:
		# 1. TIEMPO DE ESPERA: La luz se queda encendida normal
		light_energy = energia_maxima
		# Espera un tiempo aleatorio entre 2 y 6 segundos antes de fallar
		await get_tree().create_timer(randf_range(2.0, 6.0)).timeout
		
		# 2. EL FALLO: Hace una ráfaga de parpadeos rápidos (entre 3 y 7 chispazos)
		var chispazos = randi_range(3, 7)
		for i in range(chispazos):
			# Se apaga un milisegundo
			light_energy = energia_minima
			await get_tree().create_timer(randf_range(0.05, 0.1)).timeout
			
			# Se prende otro milisegundo
			light_energy = randf_range(energia_maxima * 0.6, energia_maxima)
			await get_tree().create_timer(randf_range(0.05, 0.1)).timeout
