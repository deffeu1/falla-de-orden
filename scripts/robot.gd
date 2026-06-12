extends CharacterBody3D

@onready var explosion_scene = preload("res://Escenas/explosion.tscn")

@export var velocidad : float = 1.5
@export var posicion_freno_z : float = 1.8 # Coordenada Z de tu luz

# Listas donde vamos a arrastrar nuestros modelos desde el editor
@export var modelos_sanos : Array[PackedScene] = []
@export var modelos_rotos : Array[PackedScene] = []

var es_bueno : bool = true
var frenado : bool = false

func _ready():
	# VALIDACIÓN ANTIBUGS: Si te olvidaste de cargar modelos, frena acá para evitar error % 0
	if modelos_sanos.size() == 0 or modelos_rotos.size() == 0:
		print("⚠️ ¡ERROR! Te olvidaste de arrastrar los modelos de los robots al Inspector.")
		return

	# 1. Decidir al azar si este robot nace sano o roto (50% de chances)
	es_bueno = randf() > 0.4
	
	var modelo_elegido : PackedScene
	
	# 2. Elegir un modelo al azar de la lista correspondiente
	if es_bueno:
		var indice = randi() % modelos_sanos.size()
		modelo_elegido = modelos_sanos[indice]
	else:
		var indice = randi() % modelos_rotos.size()
		modelo_elegido = modelos_rotos[indice]
	
	# 3. Instanciar (crear) el modelo visual y meterlo adentro del robot
	var visual_mesh = modelo_elegido.instantiate()
	add_child(visual_mesh)

func _physics_process(_delta):
	if not frenado:
		# CONTROL DE FRENO BLINDADO:
		# Si la posición actual en Z ya alcanzó o pasó la posición de la luz
		if global_position.z >= posicion_freno_z:
			global_position.z = posicion_freno_z # Teletransportación forzada al centro exacto
			velocity = Vector3.ZERO # Apagamos el vector de velocidad por completo
			frenado = true
			print("Robot detenido con éxito abajo de la luz.")
			
			# ─── CONEXIÓN CON EL ATRIL ───
			# Le avisamos al script de main.gd que este robot específico está esperando orden
			var main_node = get_node_or_null("/root/main")
			if main_node:
				main_node.registrar_robot_en_espera(self)
		else:
			# Si todavía no llegó, se sigue moviendo normalmente
			velocity = Vector3(0, 0, velocidad)
			
		move_and_slide()
	else:
		# Si ya fue liberado con el botón verde, se sigue moviendo hacia la salida
		move_and_slide()


# --- FUNCIÓN: Llamada por el botón ROJO del atril o la cámara ---
# --- FUNCIÓN: Llamada por el botón ROJO (Destruir) ---
func destruir():
	if is_queued_for_deletion() or not is_inside_tree():
		return

	var posicion_actual = global_transform.origin
	var interfaz = get_node_or_null("/root/main/Interfaz")
	
	if not es_bueno:
		print("¡Correcto! Robot defectuoso destruido. (+1 Punto)")
		if interfaz: interfaz.sumar_punto()
	else:
		print("¡Error! Destruiste un robot SANO. (+1 Error)")
		if interfaz: interfaz.sumar_error()
	
	# Efecto de explosión
	if explosion_scene:
		var nueva_explosion = explosion_scene.instantiate()
		get_tree().current_scene.add_child(nueva_explosion)
		nueva_explosion.global_position = posicion_actual + Vector3(0, 6.0, 0) # Ajustado al centro del robot
	
	# BORRADO SEGURO: Nos aseguramos de eliminar el nodo completo y todos sus hijos de Blender
	propagate_call("queue_free") 
	queue_free()


# --- FUNCIÓN: Llamada por el botón VERDE (Dejar pasar) ---
func dejar_pasar():
	print("El robot recibió luz verde y es expulsado de la zona de inspección.")
	
	# Para evitar cualquier bug con la física de Jolt o move_and_slide, 
	# creamos un Tween (una animación por código) que empuja al robot suavemente 
	# hacia adelante y lo saca de la pantalla para siempre.
	var tween = create_tween()
	
	# Movemos al robot 15 metros hacia adelante en el eje Z durante 2 segundos
	var posicion_destino_z = global_position.z + 15.0
	
	# Desactivamos el script para que no se meta en el _physics_process mientras se mueve
	set_physics_process(false) 
	
	# Ejecutamos el movimiento fluido hacia la salida
	tween.tween_property(self, "global_position:z", posicion_destino_z, 2.0)
	
	# Al terminar la animación, el mismo tween borra al robot del juego automáticamente
	tween.tween_callback(queue_free)
