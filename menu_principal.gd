extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 1. APAGAMOS LA CÁMARA EN EL MENÚ:
	# Buscamos la cámara que está adentro de la escena de fondo y le apagamos el script
	# Nota: Ajustá la ruta según cómo se llame tu escena de fondo en el menú (ej: $FondoFabrica/Camera3D)
	var camara = get_node_or_null("main/Camera3D") # <- Cambiá "main/Camera3D" por tu ruta real si es distinta
	if camara:
		camara.set_process(false)
		camara.set_process_input(false) # Apaga el movimiento del mouse
	
	# 2. OCULTAMOS LA INTERFAZ DE JUEGO:
	# Buscamos el CanvasLayer de la interfaz que está de fondo y lo hacemos invisible
	var interfaz_juego = get_node_or_null("Interfaz") # <- Cambiá por la ruta real a tu CanvasLayer de juego
	if interfaz_juego:
		interfaz_juego.visible = false


# Esta es la función que se ejecuta cuando tocás el botón de jugar
func _on_boton_jugar_pressed():
	# 3. PRENDEMOS TODO ANTES DE ARRANCAR:
	var camara = get_node_or_null("main/Camera3D")
	if camara:
		camara.set_process(true)
		camara.set_process_input(true)
		
	var interfaz_juego = get_node_or_null("Interfaz")
	if interfaz_juego:
		interfaz_juego.visible = true
	
	# 4. Arrancamos el juego (Acá va tu código actual para cambiar de escena o activar el juego)
	# Si estás usando cambio de escena:
	get_tree().change_scene_to_file("res://Escenas/main.tscn")
