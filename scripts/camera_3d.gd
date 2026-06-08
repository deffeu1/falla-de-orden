extends Camera3D

# Guardamos la rotación original para tener el centro
var rotacion_original : Vector3

# Qué tan sensible es el mouse al movimiento (ajustalo a tu gusto)
@export var sensibilidad : float = 0.1

# Límites de la cabeza en grados para no dar la vuelta completa
@export var limite_horizontal : float = 20.0
@export var limite_vertical : float = 15.0

# Variables para ir sumando el movimiento del mouse
var rotacion_x : float = 0.0
var rotacion_y : float = 0.0

func _ready():
	rotacion_original = rotation_degrees
	rotacion_x = rotacion_original.x
	rotacion_y = rotacion_original.y
	
	# NUEVO: Capturamos el mouse AQUÍ, cuando la cámara de juego real se activa
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Detectamos si el jugador está moviendo el mouse físicamente
	if event is InputEventMouseMotion:
		# Modificamos los ángulos según el movimiento relativo del mouse
		# El "event.relative" funciona bárbaro con el mouse capturado
		rotacion_y -= event.relative.x * sensibilidad
		rotacion_x -= event.relative.y * sensibilidad
		
		# Le ponemos un freno para que no pueda girar 360 grados la cabeza
		rotacion_x = clamp(rotacion_x, rotacion_original.x - limite_vertical, rotacion_original.x + limite_vertical)
		rotacion_y = clamp(rotacion_y, rotacion_original.y - limite_horizontal, rotacion_original.y + limite_horizontal)

func _process(delta):
	# Aplicamos la rotación de forma directa y fluida
	var destino = Vector3(rotacion_x, rotacion_y, rotacion_original.z)
	rotation_degrees = rotation_degrees.lerp(destino, 10.0 * delta)
