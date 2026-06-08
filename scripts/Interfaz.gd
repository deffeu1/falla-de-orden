extends CanvasLayer

var puntos : int = 0
var errores : int = 0
@export var max_errores : int = 3

# Vinculamos los nuevos nodos del cartel
@onready var pantalla_game_over = $PantallaGameOver
@onready var texto_puntaje_final = $PantallaGameOver/ContenedorGO/TextoPuntajeFinal

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

func actualizar_pantalla():
	var texto_puntos = get_node_or_null("TextoPuntos")
	var texto_errores = get_node_or_null("TextoErrores")
	
	if texto_puntos and texto_errores:
		texto_puntos.text = "Puntos: " + str(puntos)
		texto_errores.text = "Errores: " + str(errores) + " / " + str(max_errores)

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
