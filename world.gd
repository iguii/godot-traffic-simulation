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

var active_cars = []

func _ready() -> void:
	start_cars_with_delay()

func _process(delta: float) -> void:
	for car_name in active_cars:
		var path_3d = self.get_node_or_null("Path3D" + car_name)
		if path_3d:
			var path_follow = path_3d.get_node_or_null("PathFollow3D_" + car_name)
			if path_follow:
				path_follow.progress += move_speeds[car_name] * delta
			else:
				print("PathFollow3D not found for: " + car_name)
		else:
			print("Path3D not found for: " + car_name)

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
