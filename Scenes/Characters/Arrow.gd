extends Sprite2D

@export var decay_coefficient: int = 4000
var destination = Vector2.ZERO
var time_visible = 0
func _ready():
	pass # Replace with function body.


func _process(delta):
	if destination == Vector2.ZERO:
		time_visible = 0
		modulate.a = 0.9
		visible = false
	else:
		visible = true
		look_at(destination)
		modulate.a -= time_visible / decay_coefficient
		if modulate.a < 0.05:
			visible = false
			destination = Vector2.ZERO
			if get_node("/root/Game/TileMap").get_cell_atlas_coords(1, get_node("/root/Game/TileMap").highlighted_cell) == Vector2i(5,0):
				get_node("/root/Game/TileMap").set_cell(1, get_node("/root/Game/TileMap").highlighted_cell, 0, Vector2(1,0))
		time_visible += delta
