extends Node3D

@onready var car_pairs = [
	["CarA1", "CarB1"],
	["CarA2", "CarB2"],
	["CarA3", "CarB3"],
	["CarA4", "CarB4"],
	["CarA5", "CarB5"]
]

@onready var move_speeds = {
	"CarA1": 0.30 * 100, "CarB1": 0.30 * 100,
	"CarA2": 0.25 * 100, "CarB2": 0.25 * 100,
	"CarA3": 0.20 * 100, "CarB3": 0.20 * 100,
	"CarA4": 0.19 * 100, "CarB4": 0.19 * 100,
	"CarA5": 0.17 * 100, "CarB5": 0.17 * 100
}

# Mapa de nombres de coches a nodos
var car_nodes = {
	"CarA1": %CarA1,
	"CarA2": %CarA2,
	"CarA3": %CarA3,
	"CarA4": %CarA4,
	"CarA5": %CarA5
}

var active_cars = []
var stop: bool = false
var bodies_inside_area = []  # Lista para almacenar los cuerpos dentro del área

# Función _ready() para inicializar
func _ready() -> void:
	$TrafficLightArea1.connect("body_entered", Callable(self, "_on_body_entered"))
	$TrafficLightArea1.connect("body_exited", Callable(self, "_on_body_exited"))  # Conectar señal para cuerpos que salen
	start_cars_with_delay()
	start_traffic_light_cycle()

# Detecta cuando un cuerpo entra en el área de tráfico
func _on_body_entered(body):
	print("Cuerpo que entra: " + body.name + " (Tipo: " + str(typeof(body)) + ")")  # Imprimir tipo de cuerpo
	if body.name in car_nodes.keys():  # Verifica si el cuerpo es un coche A
		bodies_inside_area.append(body)  # Añadir el cuerpo a la lista
		print("Cuerpo colisionado: " + body.name)
		if stop:
			var car_node_path = car_nodes[body.name]  # Obtiene la ruta del nodo correspondiente
			stop_car(car_node_path)  # Detener el coche usando su nodo

# Detecta cuando un cuerpo sale del área de tráfico
func _on_body_exited(body):
	if body in bodies_inside_area:
		bodies_inside_area.erase(body)  # Eliminar el cuerpo de la lista
		print("Cuerpo salido: " + body.name)  # Registro de coches que salen

# Función para detener el coche usando la ruta de nodo del diccionario
func stop_car(car_node_path: NodePath):
	print("Deteniendo coche en: " + str(car_node_path))
	if has_node(car_node_path):  # Verifica si el nodo existe
		var car_node = get_node(car_node_path)  # Obtiene el nodo directamente usando la ruta
		if car_node.has_method("stop_movement"):  # Asegúrate de que el cuerpo tiene este método
			car_node.stop_movement()  # Detenemos el movimiento del coche
		else:
			print("El coche no tiene el método stop_movement")
	else:
		print("El nodo " + str(car_node_path) + " no se encontró")

# Controla la energía de emisión de un MeshInstance3D con un ORMMaterial3D
func set_emission_energy(target: MeshInstance3D, energy: float) -> void:
	var material := target.get_surface_override_material(0)
	
	# Verifica si el material existe y es del tipo ORMMaterial3D
	if material and material is ORMMaterial3D:
		material.set("emission_energy_multiplier", energy)
	else:
		print("El material no es de tipo ORMMaterial3D o no se encontró")

# Alterna entre las luces del semáforo
func start_traffic_light_cycle() -> void:
	while true:  # Ciclo infinito para alternar luces
		set_emission_energy($RedLight1, 1.5)  # Enciende luz roja
		set_emission_energy($GreenLight1, 0)  # Apaga luz verde
		stop = true  # Detener coches en el área
		
		# Detener solo los coches dentro del área
		print("Deteniendo coches dentro del área...")
		for body in bodies_inside_area:
			var car_node_path = car_nodes[body.name]  # Obtiene la ruta del nodo correspondiente
			stop_car(car_node_path)  # Detiene el coche usando su nodo

		await get_tree().create_timer(3.0).timeout  # Espera 3 segundos en Rojo

		set_emission_energy($RedLight1, 0)     # Apaga luz roja
		set_emission_energy($YellowLight1, 1.5) # Enciende luz amarilla

		await get_tree().create_timer(1.5).timeout  # Espera 1.5 segundos en Amarillo

		set_emission_energy($YellowLight1, 0)   # Apaga luz amarilla
		set_emission_energy($GreenLight1, 1.5)  # Enciende luz verde
		stop = false  # Permitir el movimiento de coches nuevamente

		await get_tree().create_timer(3.0).timeout  # Espera 3 segundos en Verde

# Función _process() para actualizar el movimiento de los coches
func _process(delta: float) -> void:
	if not stop:  # Solo mover coches si no están parados
		for car_name in active_cars:
			var path_3d = self.get_node_or_null("Path3D" + car_name)
			if path_3d:
				var path_follow = path_3d.get_node_or_null("PathFollow3D_" + car_name)
				if path_follow:
					path_follow.progress += move_speeds[car_name] * delta
				else:
					print("PathFollow3D no encontrado para: " + car_name)
			else:
				print("Path3D no encontrado para: " + car_name)

func start_cars_with_delay() -> void:
	for i in range(car_pairs.size()):
		var timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.start(0.5 * i)  # Delayed start for each pair
		await timer.timeout
		var pair = car_pairs[i]
		for car_name in pair:
			print(car_name + " started!")
			active_cars.append(car_name)
