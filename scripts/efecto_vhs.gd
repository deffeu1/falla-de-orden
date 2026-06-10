extends TextureRect

# Variables para controlar la intensidad desde el Inspector si querés
@export var velocidad_estatica : float = 10.0
@export var opacidad_base : float = 0.15 # Qué tan oscuro es el filtro (0.0 a 1.0)

var tiempo : float = 0.0

func _ready():
	# Nos aseguramos por código de que el filtro ignore el mouse y no bloquee clicks
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	tiempo += delta
	
	# 1. EFECTO MOVIMIENTO: Desfasamos la textura al azar en cada frame
	# Esto hace que las líneas y el ruido "tiemblen" como estática real
	texture_position_offset()

	# 2. EFECTO PARPADEO: Hacemos que la opacidad oscile suavemente con una onda Seno
	# Le sumamos un ruido matemático (randf) muy chico para simular interferencia
	var parpadeo = opacidad_base + (sin(tiempo * 20.0) * 0.02) + (randf_range(-0.01, 0.01))
	
	# Aplicamos la opacidad modificando el canal Alpha (A) del Self Modulate
	self_modulate.a = clamp(parpadeo, 0.05, 0.25)

func texture_position_offset():
	# Si estás usando una textura que se repite (Tile), podemos mover sus coordenadas.
	# Si no, simplemente movemos un pelín el nodo de lugar de forma caótica:
	position.y = randf_range(-2.0, 2.0)
	position.x = randf_range(-1.0, 1.0)
