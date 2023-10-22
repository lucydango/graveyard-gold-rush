extends Control

@onready var tilemap = get_node("/root/Game/TileMap")
var points = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_dig_finish(cell):
	if get_node("/root/Game").run_game:
		points += tilemap.points_dict[cell]
		get_node("PanelContainer/Label").text = str(snapped(points, 0))


func _on_texture_button_pressed():
	get_node("HowToPlayPanel").visible = false
	get_node("/root/Game").run_game = true
