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


# --- FUNCIÓN CORREGIDA Y UNIFICADA ---
func _on_zona_fuga_body_entered(body: Node3D) -> void:
	# Preguntamos si el objeto que entró es un robot (tus robots son CharacterBody3D)
	if body is CharacterBody3D: 
		
		# Si el robot que se escapó era MALO/DEFECTUOSO...
		if not body.es_bueno:
			print("¡Se escapó un robot defectuoso! (+1 Error)")
			var interfaz = get_node_or_null("/root/main/Interfaz")
			if interfaz:
				interfaz.sumar_error() # Te suma un error a tus vidas
		else:
			# Si era un robot sano, se despacha bien
			print("¡Robot sano despachado correctamente! (+1 Punto)")
			var interfaz = get_node_or_null("/root/main/Interfaz")
			if interfaz:
				interfaz.sumar_punto() # ¡Te suma un punto por dejarlo pasar!
		
		# Al final, borramos el robot del juego para que no siga cayendo al infinito
		body.queue_free()
