extends TileMap

# This is such bullshit that I have to do this, but you can't set
# custom data on a per tile basis in godot so this is the workaround
var points_dict = {}
var highlighted_cell = Vector2.ZERO
func _ready():
	for i in get_used_cells(1):
		if get_cell_tile_data(1, i).get_custom_data("Diggable"):
			points_dict[i] = randi_range(1, 1000)
			if points_dict[i] < 800:
				points_dict[i] /= 4
			else:
				points_dict[i] *= 2

func _process(delta):
	pass
