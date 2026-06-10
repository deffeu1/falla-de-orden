extends CanvasLayer

var puntos : int = 0
var errores : int = 0
@export var max_errores : int = 3

# Vinculamos los nuevos nodos del cartel
@onready var pantalla_game_over = $PantallaGameOver
@onready var texto_puntaje_final = $PantallaGameOver/ContenedorGO/TextoPuntajeFinal
@onready var pantalla_pausa = $PantallaPausa

func _ready():
	# Nos aseguramos de que el cartel empiece oculto al reiniciar
	pantalla_game_over.visible = false
	actualizar_pantalla()
	# Si estamos en el menú principal, arranca invisible
	if get_tree().current_scene.name == "MenuPrincipal":
		visible = false

func sumar_punto():
	puntos += 1
	actualizar_pantalla()

func sumar_error():
	errores += 1
	actualizar_pantalla()
	
	if errores >= max_errores:
		game_over()

# --- FUNCIÓN CORREGIDA CON ACCESO ÚNICO (%) ---
func actualizar_pantalla():
	# Usamos get_node_or_null con el símbolo % para encontrarlos en cualquier contenedor
	var texto_puntos = get_node_or_null("%TextoPuntos")
	var texto_errores = get_node_or_null("%TextoErrores")
	
	if texto_puntos and texto_errores:
		# Formato estilo terminal: Rellena con ceros a la izquierda (ej: PRODUCCION: 0005)
		texto_puntos.text = "PRODUCCION: %04d" % puntos
		texto_errores.text = "FALLAS DE ORDEN: " + str(errores) + " / " + str(max_errores)

func game_over():
	pantalla_game_over.visible = true
	
	# CAMBIADO: Usamos "texto_puntaje_final" que es el nombre correcto
	texto_puntaje_final.text = "Puntos conseguidos: " + str(puntos)
	
	get_tree().paused = true
	
	# NUEVO: Devolvemos el mouse a la normalidad para poder clickear el botón
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_boton_reiniciar_pressed():
	print("¡Click detectado! Reiniciando fábrica...") # <- Agregamos este print para probar
	get_tree().paused = false
	get_tree().reload_current_scene()

func _input(event):
	# Si presionás ESCAPE y NO perdiste (Game Over invisible)
	if event.is_action_pressed("ui_cancel") and not pantalla_game_over.visible:
		toggle_pausa()

func toggle_pausa():
	# Invertimos el estado de pausa (si estaba pausado, pasa a falso, y viceversa)
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	
	# Mostramos u ocultamos el menú visual
	pantalla_pausa.visible = nuevo_estado
	
	# Manejamos el mouse según el estado
	if nuevo_estado:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   # Mostramos el mouse para clickear botones
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Ocultamos el mouse para seguir jugando

# 1. BOTÓN REANUDAR
func _on_boton_reanudar_pressed():
	toggle_pausa() # Cerramos la pausa y devolvemos el mouse a la normalidad

# 2. BOTÓN REINICIAR DESDE PAUSA
func _on_boton_reiniciar_pausa_pressed():
	get_tree().paused = false # ¡Es clave despausar antes de recargar!
	get_tree().reload_current_scene()

# 3. BOTÓN VOLVER AL MENÚ
func _on_boton_volver_menu_pressed():
	get_tree().paused = false # ¡Es clave despausar antes de cambiar de escena!
	get_tree().change_scene_to_file("res://Escenas/MenuPrincipal.tscn") # Ajustá la ruta si es distinta
