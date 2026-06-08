extends CharacterBody3D

@onready var explosion_scene = preload("res://Escenas/Explosion.tscn")

@export var velocidad = 1.5

# Listas donde vamos a arrastrar nuestros modelos desde el editor
@export var modelos_sanos : Array[PackedScene] = []
@export var modelos_rotos : Array[PackedScene] = []

var es_bueno : bool = true

func _ready():
	# 1. Decidir al azar si este robot nace sano o roto (50% de chances)
	es_bueno = randf() > 0.5
	
	var modelo_elegido : PackedScene
	
	# 2. Elegir un modelo al azar de la lista correspondiente
	if es_bueno:
		# Elegimos uno al azar de la lista de sanos
		var indice = randi() % modelos_sanos.size()
		modelo_elegido = modelos_sanos[indice]
	else:
		# Elegimos uno al azar de la lista de rotos
		var indice = randi() % modelos_rotos.size()
		modelo_elegido = modelos_rotos[indice]
	
	# 3. Instanciar (crear) el modelo visual y meterlo adentro del robot
	var visual_mesh = modelo_elegido.instantiate()
	add_child(visual_mesh)

func _physics_process(_delta):
	# Mover el robot hacia adelante (en el eje Z en este caso)
	velocity = Vector3(0, 0, velocidad)
	move_and_slide()

# Esta función detecta los clicks del mouse sobre el CollisionShape3D del robot
func _input_event(_camera, event, _click_position, _normal, _shape_idx):
	# Si el robot ya se está borrando o no está en el mapa, salimos
	if is_queued_for_deletion() or not is_inside_tree():
		return

	# ¿El jugador hizo click (apretando el botón)?
	if event is InputEventMouseButton and event.pressed:
		
		# --- CLICK IZQUIERDO ÚNICO: Se usa para DESCARTAR/DESTRUIR el robot ---
		if event.button_index == MOUSE_BUTTON_LEFT:
			var posicion_actual = global_transform.origin
			var interfaz = get_node_or_null("/root/main/Interfaz")
			
			if not es_bueno:
				# ¡Correcto! Destruiste un robot roto antes de que se escape
				print("¡Correcto! Robot defectuoso destruido. (+1 Punto)")
				if interfaz: interfaz.sumar_punto()
			else:
				# ¡Error! Rompiste un robot que estaba perfecto
				print("¡Error! Destruiste un robot SANO.(+1 Error)")
				if interfaz: interfaz.sumar_error()
			
			# Efecto de explosión (vuela en cubitos low-poly)
			var nueva_explosion = explosion_scene.instantiate()
			nueva_explosion.global_position = posicion_actual + Vector3(0, 6.0, -4)
			get_tree().current_scene.add_child(nueva_explosion)
			
			# Borramos el robot del juego
			queue_free()
