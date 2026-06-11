extends Camera3D

# --- VARIABLES DE MOVIMIENTO ---
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
	
	# 🟢 CLAVE 1: Al empezar el gameplay, ocultamos y capturamos el mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# 1. Giro de la cabeza (Solo funciona si el mouse está oculto/capturado)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotacion_y -= event.relative.x * sensibilidad
		rotacion_x -= event.relative.y * sensibilidad
		
		rotacion_x = clamp(rotacion_x, rotacion_original.x - limite_vertical, rotacion_original.x + limite_vertical)
		rotacion_y = clamp(rotacion_y, rotacion_original.y - limite_horizontal, rotacion_original.y + limite_horizontal)
	
	# 2. DETECCIÓN DE CLICKS (Hacia donde apunta la mira del centro)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Si el juego está pausado, no disparamos el rayo
		if get_tree().paused:
			return
			
		# 🟢 CLAVE 2: Como el mouse está oculto, proyectamos el rayo desde el CENTRO EXACTO de la pantalla (donde está la mira)
		var centro_pantalla = get_viewport().get_visible_rect().size / 2
		var desde = project_ray_origin(centro_pantalla)
		var hacia = desde + project_ray_normal(centro_pantalla) * 1000.0
		
		var espacio_fisico = get_world_3d().direct_space_state
		var parametros_rayo = PhysicsRayQueryParameters3D.create(desde, hacia)
		parametros_rayo.collide_with_areas = true 
		
		var resultado = espacio_fisico.intersect_ray(parametros_rayo)
		
		if resultado:
			var objeto_chocado = resultado.collider
			var main_node = get_node_or_null("/root/main")
			if main_node:
				if "verde" in objeto_chocado.name.to_lower():
					main_node._on_boton_verde_area_3d_input_event(null, event, Vector3.ZERO, Vector3.ZERO, 0)
				elif "rojo" in objeto_chocado.name.to_lower():
					main_node._on_boton_rojo_area_3d_input_event(null, event, Vector3.ZERO, Vector3.ZERO, 0)


func _process(delta):
	var destino = Vector3(rotacion_x, rotacion_y, rotacion_original.z)
	rotation_degrees = rotation_degrees.lerp(destino, 10.0 * delta)
