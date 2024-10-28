extends Node3D

# Load the scene resource you want to spawn
var object_to_spawn = preload("res://car_2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Optional: spawn an object when the game starts
	spawn_object(Vector3(0, 0, 0))

# Function to spawn the object at a specified location
func spawn_object(position: Vector3) -> void:
	# Create an instance of the loaded scene
	var instance = object_to_spawn.instance()
	# Set the position of the spawned instance
	instance.translation = position
	# Add it to the current scene
	add_child(instance)
