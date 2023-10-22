extends PointLight2D

@onready var start_pos = position
func _ready():
	pass # Replace with function body.


func _process(delta):
	var rand_move = Vector2(randf_range(-5, 5) * delta, randf_range(-5, 5) * delta)
	if ((position + rand_move) - start_pos).length() < 512:
		position += rand_move * 2
