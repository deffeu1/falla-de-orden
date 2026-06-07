extends GPUParticles3D

func _ready():
	# Activar la explosión apenas nace
	emitting = true
	# Esperar 2 segundos (lo que dura el efecto) y borrar la explosión del juego
	await get_tree().create_timer(2.0).timeout
	queue_free()
