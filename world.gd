extends Node3D

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	const move_speed := 0.5
	print(delta)
	%PathFollow3D_Car2.progress += move_speed + delta
	%PathFollow3D.progress = move_speed * delta

	
