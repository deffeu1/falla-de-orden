extends CanvasLayer

var puntos : int = 0
var errores : int = 0
@export var max_errores : int = 3

@onready var texto_puntos = $TextoPuntos
@onready var texto_errores = $TextoErrores

func _ready():
	actualizar_pantalla()

# Esta función suma puntos cuando acertás
func sumar_punto():
	puntos += 1
	actualizar_pantalla()

# Esta función suma errores cuando te equivocás
func sumar_error():
	errores += 1
	actualizar_pantalla()
	
	if errores >= max_errores:
		game_over()

# Dedicada a refrescar los textos en pantalla
func actualizar_pantalla():
	texto_puntos.text = "Puntos: " + str(puntos)
	texto_errores.text = "Errores: " + str(errores) + " / " + str(max_errores)

func game_over():
	print("¡PERDISTE! La fábrica cerró por incompetencia.")
	# Por ahora congelamos el juego al perder
	get_tree().paused = true
