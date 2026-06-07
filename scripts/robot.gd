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
	# ¿El jugador hizo un click?
	if event is InputEventMouseButton and event.pressed:
		
		# --- CLICK IZQUIERDO: El jugador dice que está SANO ---
		if event.button_index == MOUSE_BUTTON_LEFT:
			if es_bueno:
				print("¡Correcto! Dejaste pasar un robot sano.")
			else:
				print("¡Error! Dejaste pasar un robot ROTO.")
			
			# Borra el robot del juego inmediatamente
			queue_free() 
			
		# --- CLICK DERECHO: El jugador dice que está ROTO ---
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if not es_bueno:
				print("¡Correcto! Descartaste un robot defectuoso.")
			else:
				print("¡Error! Descartaste un robot que estaba SANO.")
			
			# --- ¡ACÁ VA LA EXPLOSIÓN! ---
			# 1. Creamos la copia de la explosión
			var nueva_explosion = explosion_scene.instantiate()
			# 2. La ponemos en la misma posición exacta del robot actual
			nueva_explosion.global_position = self.global_position + Vector3(0, 6.0, -4)
			# 3. La metemos al escenario principal del juego
			get_parent().add_child(nueva_explosion)
			
			# Borra el robot del juego inmediatamente
			queue_free()
