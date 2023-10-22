extends Node2D


signal dig_finish(cell)
@onready var kb = get_node("PlayerBody")
@onready var sprite = get_node("PlayerBody/PlayerSprite")
@onready var audio = get_node("AudioPlayer")
@onready var tilemap = get_node("/root/Game/TileMap")
@onready var digsound = preload("res://Sounds/dig.wav")
@onready var detectsound = preload("res://Sounds/detector.wav")

@export var speed = 30
@export var sprint_mod = 2

var lock_movement = false
var do_idle_anim = true

var interacting_with_cell

var wait_to_play_time = -1
func _ready():
	sprite.play()

func _process(delta):
	if wait_to_play_time > -1 && wait_to_play_time < 0:
		audio.playing = true
		wait_to_play_time = -1
	elif wait_to_play_time > -1:
		wait_to_play_time -= delta
	if !get_node("/root/Game").run_game:
		return
	movement()

func movement():
	var mv = Vector2.ZERO
	if !lock_movement:
		if Input.is_action_pressed("up"):
			mv += Vector2(0,-1)
		if Input.is_action_pressed("down"):
			mv += Vector2(0,1)
		if Input.is_action_pressed("left"):
			mv += Vector2(-1,0)
		if Input.is_action_pressed("right"):
			mv += Vector2(1,0)
		kb.set_velocity(mv * speed)
		kb.move_and_slide()
	elif sprite.animation == "detect" && (Input.is_action_pressed("up") || Input.is_action_pressed("down") || Input.is_action_pressed("left") || Input.is_action_pressed("right")):
		print("pog")
		audio.playing = false
		do_idle_anim = true
		lock_movement = false
		audio.volume_db = -60
	if mv != Vector2.ZERO:
		if mv.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		sprite.animation = "walk"
		sprite.set_speed_scale(1)
	elif do_idle_anim:
		sprite.animation = "idle"
		sprite.set_speed_scale(0.4)
		
	if Input.is_action_just_pressed("detect"):
		do_idle_anim = false
		lock_movement = true
		sprite.animation = "detect"
		sprite.set_speed_scale(1)
		audio.stream = detectsound
		audio.volume_db = -12
		wait_to_play_time = 1


func _on_player_sprite_animation_finished():
	
	if sprite.animation == "dig":
		emit_signal("dig_finish",interacting_with_cell)
	if sprite.animation == "detect":
		detect();
	do_idle_anim = true
	lock_movement = false
	sprite.animation = "idle"
	sprite.set_speed_scale(0.4)
	sprite.play()
	
func dig(cell):
	if cell == tilemap.local_to_map(get_node("PlayerBody/PlayerCam/Arrow").destination):
		get_node("PlayerBody/PlayerCam/Arrow").destination = Vector2.ZERO
	interacting_with_cell = cell
	sprite.animation = "dig"
	do_idle_anim = false
	lock_movement = true
	sprite.set_speed_scale(1)
	audio.stream = digsound
	audio.volume_db = -2
	wait_to_play_time = 2.1


func detect():
	var radius = 750
	var best_grave = Vector2i.ZERO
	var best_points = 0
	var tilemap = get_node("/root/Game/TileMap")
	for c in tilemap.get_used_cells(1): 
		if tilemap.get_cell_tile_data(1, c).get_custom_data("Diggable") && (radius > (global_position - tilemap.map_to_local(c)).length()):
			if tilemap.points_dict[c] > best_points:
				best_points = tilemap.points_dict[c]
				best_grave = c
	if best_grave != Vector2i.ZERO:
		get_node("PlayerBody/PlayerCam/Arrow").destination = tilemap.map_to_local(best_grave)
		tilemap.set_cell(1, best_grave, 0, Vector2(5,0))
		tilemap.highlighted_cell = best_grave

