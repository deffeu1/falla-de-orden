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
func _on_boton_verde_area_3d_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# 🎬 ANIMACIÓN: Apunta correctamente a través del nodo "atril"
		animar_boton($atril/Boton_Verde)
		
		if robot_actual and is_instance_valid(robot_actual):
			print("boton verde presionado")
			
			if robot_actual.es_bueno:
				print("robot sano aprobado")
				if interfaz: interfaz.sumar_punto()
			else:
				print("dejaste pasar un robot malo")
				if interfaz: interfaz.sumar_error()
			
			robot_actual.dejar_pasar()
			robot_actual = null # Puesto libre para el que viene atrás
			
			# ─── REANUDAR FÁBRICA ───
			if timer and timer.is_stopped():
				print("generando otro robot")
				timer.start()


# --- SEÑAL DEL BOTÓN ROJO (DESTRUIR) ---
func _on_boton_rojo_area_3d_input_event(_camera, event, _event_position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# 🎬 ANIMACIÓN: Apunta correctamente a través del nodo "atril"
		animar_boton($atril/Boton_Rojo)
		
		if robot_actual and is_instance_valid(robot_actual):
			print("boton rojo presionado")
			
			robot_actual.destruir() 
			robot_actual = null # Puesto libre
			
			# ─── REANUDAR FÁBRICA ───
			if timer and timer.is_stopped():
				print("♻️ Espacio liberado por destrucción. Reanudando Timer...")
				timer.start()


# --- ZONA DE FUGA REFORMADA ---
func _on_zona_fuga_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D: 
		print("robot viejo removido del mapa al llegar al final.")
		body.queue_free()


# Variable nueva para recordar la posición original real de los botones de fábrica
var posiciones_originales : Dictionary = {}

# --- FUNCIÓN: ANIMACIÓN DE FEEDBACK VISUAL (CORREGIDA ANTI-CLICKS RÁPIDOS) ---
func animar_boton(nodo_boton: Node3D):
	if not nodo_boton:
		return
		
	# 1. Si es la primera vez que clickeamos este botón, guardamos su posición verdadera de fábrica
	if not posiciones_originales.has(nodo_boton):
		posiciones_originales[nodo_boton] = nodo_boton.position
		
	var pos_original = posiciones_originales[nodo_boton]
	
	# 2. SISTEMA ANTI-SPAM CORREGIDO: Usamos has_meta para evitar el error interno de Godot en el primer click
	var tween_viejo = null
	if nodo_boton.has_meta("mi_tween"):
		tween_viejo = nodo_boton.get_meta("mi_tween")
		
	if tween_viejo and tween_viejo.is_valid():
		tween_viejo.kill() # Matamos la animación anterior a mitad de camino
	
	# 3. Creamos la nueva animación limpia
	var tween = create_tween()
	nodo_boton.set_meta("mi_tween", tween) # Guardamos este tween en el botón para poder matarlo si hay otro click
	
	# Calculamos el hundimiento siempre en base a la posición original real
	var pos_hundido = pos_original + Vector3(0, -0.1, 0)
	
	# Ejecutamos el hundimiento rápido y el regreso elástico forzado a la posición de fábrica
	tween.tween_property(nodo_boton, "position", pos_hundido, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo_boton, "position", pos_original, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
