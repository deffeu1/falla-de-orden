extends Node3D

# Guardamos al robot que está actualmente esperando bajo la luz
var robot_actual: CharacterBody3D = null

@onready var robot_scene = preload("res://Escenas/Robot.tscn")
@onready var spawn_point = $SpawnPoint
@onready var interfaz = $Interfaz 
@onready var timer = $Timer 

func _on_timer_timeout():
	# 1. Antes de crear un robot, contamos cuántos hay en la fila del escenario
	var cantidad_robots = 0
	for nodo in get_children():
		if nodo is CharacterBody3D:
			cantidad_robots += 1
	
	# 2. Si ya llegamos al límite de 4 robots en el mapa, frenamos el Timer y salimos
	if cantidad_robots >= 4:
		print("🛑 Fila llena (4 robots). Pausando producción temporalmente.")
		if timer:
			timer.stop()
		return # Cortamos acá, no creamos el robot número 5

	# 3. Si hay lugar, creamos una copia del robot normalmente
	var nuevo_robot = robot_scene.instantiate()
	add_child(nuevo_robot)
	nuevo_robot.global_position = spawn_point.global_position
	
	# 4. VOLVEMOS A CHEQUEAR: Si con este nuevo robot recién creado llegamos justo a 4,
	# apagamos el Timer de inmediato para que no intente calcular el próximo ciclo.
	if cantidad_robots + 1 >= 4:
		print("🚨 Se alcanzó el límite máximo de 4 robots en pantalla. Frenando reloj.")
		if timer:
			timer.stop()


# --- FUNCIÓN: El robot avisa acá cuando se frena en la luz ---
func registrar_robot_en_espera(robot):
	robot_actual = robot
	print("🤖 Robot listo para inspección. Puesto de control activo.")


# --- SEÑAL DEL BOTÓN VERDE (DEJAR PASAR) ---
func _on_boton_verde_area_3d_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if robot_actual and is_instance_valid(robot_actual):
			print("🟢 Botón VERDE presionado: Dejando pasar robot...")
			
			if robot_actual.es_bueno:
				print("¡Punto! Despachaste un robot sano.")
				if interfaz: interfaz.sumar_punto()
			else:
				print("¡Falla! Dejaste pasar una unidad dañada.")
				if interfaz: interfaz.sumar_error()
			
			robot_actual.dejar_pasar()
			robot_actual = null # Puesto libre para el que viene atrás
			
			# ─── REANUDAR FÁBRICA ───
			# Como liberamos un puesto, nos aseguramos de que el Timer vuelva a arrancar
			if timer and timer.is_stopped():
				print("♻️ Espacio liberado en la fila. Reanudando Timer...")
				timer.start()


# --- SEÑAL DEL BOTÓN ROJO (DESTRUIR) ---
func _on_boton_rojo_area_3d_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if robot_actual and is_instance_valid(robot_actual):
			print("🔴 Botón ROJO presionado: Activando trampa de destrucción...")
			
			robot_actual.destruir() 
			robot_actual = null # Puesto libre
			
			# ─── REANUDAR FÁBRICA ───
			# El robot explotó, por ende la cola bajó a 3. Arrancamos el Timer.
			if timer and timer.is_stopped():
				print("♻️ Espacio liberado por destrucción. Reanudando Timer...")
				timer.start()


# --- ZONA DE FUGA REFORMADA ---
func _on_zona_fuga_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D: 
		print("Robot viejo removido del mapa al llegar al final.")
		body.queue_free()
