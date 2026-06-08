extends Node3D

# Cargamos la plantilla del Robot que creamos en el Paso 3
@onready var robot_scene = preload("res://Escenas/Robot.tscn")
@onready var spawn_point = $SpawnPoint

func _on_timer_timeout():
	# 1. Creamos una copia del robot
	var nuevo_robot = robot_scene.instantiate()
	
	# 2. Lo metemos en el juego PRIMERO
	add_child(nuevo_robot)
	
	# 3. AHORA SÍ le asignamos la posición del spawnpoint
	nuevo_robot.global_position = spawn_point.global_position
	


func _on_zona_fuga_body_entered(body):
	# Preguntamos si lo que entró a la zona es un Robot
	if body.has_method("_input_event"): 
		
		# Buscamos la interfaz para poder actualizar el marcador
		var interfaz = get_node_or_null("Interfaz")
		
		# Si el robot era de los MALOS y se nos escapó...
		if not body.es_bueno:
			print("¡Se escapó un robot roto de la fábrica!")
			if interfaz:
				interfaz.sumar_error()
		
		# --- ¡ACÁ SE HACE EL CAMBIO! ---
		# Si el robot era de los BUENOS y llegó al final con éxito...
		else:
			print("¡Robot sano despachado correctamente! (+1 Punto)")
			if interfaz:
				interfaz.sumar_punto() # <--- Sumamos punto por dejarlo pasar
		
		# En ambos casos, borramos al robot del juego para liberar memoria
		body.queue_free()
		
#func _ready():
	# (Acá tenés tu código actual de los Timers y configuraciones...)

	# Ocultamos el cursor y lo bloqueamos al centro del juego
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
