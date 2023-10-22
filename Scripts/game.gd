extends Node2D

signal dig(cell)
@export var gametime: int = 90
@onready var map = get_node("TileMap")
@onready var player = get_node("Player")
@onready var copper_pre = preload("res://Scenes/Characters/Copper.tscn")
@onready var busted = preload("res://Scenes/busted.tscn")
var ticker = 1

var run_game = true

func _ready():
	connect("dig", player.dig)
	player.connect("dig_finish", update_grave)
func _process(delta):
	if !run_game:
		return
	ticker -= delta
	var seconds = gametime % 60
	if seconds < 10:
		seconds = "0"+str(seconds)
	else: seconds = str(seconds)
	player.get_node("PlayerBody/PlayerCam/PlayerHUD/TimerContainer/TimerLabel").text = "0"+str( snapped(gametime/60, 0) )+":"+seconds
	if ticker <= 0: 
		gametime -= 1
		ticker = 1
	if gametime == 60:
		var newc = copper_pre.instantiate()
		add_child(newc)
		gametime -= 1
		player.get_node("PlayerBody/PlayerCam/PlayerHUD/Alert").visible = true
	# no time to implement this in a less terrible way
	if gametime == 58: player.get_node("PlayerBody/PlayerCam/PlayerHUD/Alert").visible = false
	if gametime == 57: player.get_node("PlayerBody/PlayerCam/PlayerHUD/Alert").visible = true
	if gametime == 56: player.get_node("PlayerBody/PlayerCam/PlayerHUD/Alert").visible = false
	if gametime == 0:
		var b = busted.instantiate()
		player.get_node("PlayerBody/PlayerCam").add_child(b)
		b.get_node("Timeout").visible = true
		b.get_node("Busted").visible = false
		
	if Input.is_action_just_pressed("click"):
		var clickpos = map.local_to_map(get_global_mouse_position())
		var data = map.get_cell_tile_data(1, clickpos)
		if data:
			if data.get_custom_data("Diggable") and (get_global_mouse_position() - player.kb.global_position).length() < 8:
				emit_signal("dig", clickpos)

func update_grave(cell):
	if run_game:
		map.set_cell(1, cell, 0, Vector2(2,0))
