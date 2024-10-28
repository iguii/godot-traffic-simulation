extends Node3D

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	const move_speed_B1 := 0.4
	const move_speed_B2 := 0.30
	const move_speed_B3 := 0.20
	print(delta)
	%PathFollow3D_CarB1.progress += move_speed_B1 + delta
	%PathFollow3D_CarB2.progress += move_speed_B2 + delta
	%PathFollow3D_CarB3.progress += move_speed_B3 + delta



	
