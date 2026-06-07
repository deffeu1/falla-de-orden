extends Node3D

# Cargamos la plantilla del Robot que creamos en el Paso 3
@onready var robot_scene = preload("res://Escenas/Robot.tscn")
@onready var spawn_point = $SpawnPoint

func _on_timer_timeout():
	# 1. Creamos una copia del robot
	var nuevo_robot = robot_scene.instantiate()
	
	# 2. Lo metemos en el juego PRIMERO
	add_child(nuevo_robot)
	
	# 3. AHORA SÍ le asignamos la posición del spawnpoint
	nuevo_robot.global_position = spawn_point.global_position
	
