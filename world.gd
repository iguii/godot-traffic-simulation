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

var original_speeds = {}  # Para almacenar las velocidades originales
var active_cars = []

# Traffic Lights
var stop: bool = false

# Controla la energía de emisión de un MeshInstance3D con un ORMMaterial3D
func set_emission_energy(target: MeshInstance3D, energy: float) -> void:
	var material := target.get_surface_override_material(0)
	if material and material is ORMMaterial3D:
		material.set("emission_energy_multiplier", energy)
	else:
		print("El material no es de tipo ORMMaterial3D o no se encontró")

# Alterna entre las luces del semáforo
func start_traffic_light_cycle() -> void:
	set_emission_energy($RedLight1, 1.5)
	stop = true
	set_emission_energy($YellowLight1, 0)
	set_emission_energy($GreenLight1, 0)

	await get_tree().create_timer(3.0).timeout

	set_emission_energy($RedLight1, 0)
	set_emission_energy($YellowLight1, 1.5)
	stop = true

	await get_tree().create_timer(3.0).timeout

	set_emission_energy($YellowLight1, 0)
	set_emission_energy($GreenLight1, 1.5)
	stop = false
	# Reanudar la velocidad de los autos cuando el semáforo está en verde
	for car_name in active_cars:
		if original_speeds.has(car_name):
			move_speeds[car_name] = original_speeds[car_name]


	await get_tree().create_timer(1.5).timeout

	start_traffic_light_cycle()

func stop_car(car_name: String):
	print("Deteniendo coche: " + car_name)
	# Establece la velocidad a cero
	move_speeds[car_name] = 0  # Detener el coche ajustando su velocidad a cero

# Detener el tráfico en rojo
func _on_body_entered(body):
	if body.name in move_speeds.keys():  # Verifica si el cuerpo es un auto
		print("Cuerpo colisionado: " + body.name)
		if stop:
			stop_car(body.name)  # Deten el auto

# Función _ready() para inicializar
func _ready() -> void:
	$TrafficLightArea1.connect("body_entered", Callable(self, "_on_body_entered"))
	$TrafficLightArea1.connect("body_exited", Callable(self, "_on_body_exited"))  # Conectar señal para cuerpos que salen
	start_cars_with_delay()
	
	# Almacena las velocidades originales
	for car_name in move_speeds.keys():
		original_speeds[car_name] = move_speeds[car_name]
	
	start_traffic_light_cycle()

func _process(delta: float) -> void:
	for car_name in active_cars:
		var path_3d = self.get_node_or_null("Path3D" + car_name)
		if path_3d:
			var path_follow = path_3d.get_node_or_null("PathFollow3D_" + car_name)
			if path_follow:
				# Solo mueve el coche si no está detenido
				if move_speeds[car_name] > 0:
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
		timer.start(0.5 * i)
		await timer.timeout
		var pair = car_pairs[i]
		for car_name in pair:
			print(car_name + " started!")
			active_cars.append(car_name)
