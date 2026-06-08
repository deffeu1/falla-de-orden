extends Camera3D

# --- VARIABLES DE MOVIMIENTO (Las que ya tenías) ---
var rotacion_original : Vector3
@export var sensibilidad : float = 0.1
@export var limite_horizontal : float = 20.0
@export var limite_vertical : float = 15.0

var rotacion_x : float = 0.0
var rotacion_y : float = 0.0

func _ready():
	rotacion_original = rotation_degrees
	rotacion_x = rotacion_original.x
	rotacion_y = rotacion_original.y
	
	# Capturamos el mouse para el modo FPS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Giro de la cabeza estilo FPS (El que ya funcionaba bárbaro)
	if event is InputEventMouseMotion:
		rotacion_y -= event.relative.x * sensibilidad
		rotacion_x -= event.relative.y * sensibilidad
		
		rotacion_x = clamp(rotacion_x, rotacion_original.x - limite_vertical, rotacion_original.x + limite_vertical)
		rotacion_y = clamp(rotacion_y, rotacion_original.y - limite_horizontal, rotacion_original.y + limite_horizontal)


func _process(delta):
	# Aplicamos el movimiento fluido de la cámara
	var destino = Vector3(rotacion_x, rotacion_y, rotacion_original.z)
	rotation_degrees = rotation_degrees.lerp(destino, 10.0 * delta)


# --- NUEVA FUNCIÓN: DETECCIÓN DE CLICS FPS ---
func _unhandled_input(event):
	# Si hace click izquierdo...
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Si el juego está pausado, no disparamos
		if get_tree().paused:
			return

		# Lanzamos el rayo matemático desde el centro de la cámara hacia adelante
		var space_state = get_world_3d().direct_space_state
		var query_start = global_transform.origin
		var query_end = query_start - global_transform.basis.z * 100.0 # 100 metros de alcance
		
		var query = PhysicsRayQueryParameters3D.create(query_start, query_end)
		var result = space_state.intersect_ray(query)

		# Si el rayo choca contra algo...
		if result:
			var objeto_colisionado = result.collider
			
			# LINEA NUEVA PARA DEBUGGEAR: Nos dice en la consola CONTRA QUÉ chocó el rayo
			print("El rayo chocó contra: ", objeto_colisionado.name)
			
			if objeto_colisionado.has_method("destruir"):
				objeto_colisionado.destruir()
			else:
				# LINEA NUEVA PARA DEBUGGEAR: Nos avisa si chocó pero el script no tiene la función
				print("Chocó, pero el objeto no tiene la función 'destruir'")
