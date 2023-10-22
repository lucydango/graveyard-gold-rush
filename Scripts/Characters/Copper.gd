extends Node2D

@onready var kb = get_node("Body")
@onready var radius_sprite = get_node("Body/RadiusArea/RadiusCollision/RadiusSprite")
@onready var sprite = get_node("Body/CopperSprite")
@onready var busted = preload("res://Scenes/busted.tscn")
@export var speed: int = 25
@export var start_node: int = 0

var current_id = 0
var path = []
var chase_path = []
var temp_blacklist = []
var a_star = AStar2D.new()
var graph_size = 0
var nav_agent

var move = true
var caught = false
var chasing = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var ticker = 0
	for i in get_node("/root/Game/NavMap").get_children():
		a_star.add_point(ticker, i.global_position)
		ticker += 1	
	
	#WHY DOES THIS WORK BUT THE EXACT SAME THING IN THE OTHER FOR LOOP DOESNT
	for i in range(ticker):
		if i > 0:
			a_star.connect_points(i-1,i)
	path = a_star.get_point_path(0,ticker - 1)
	position = path[start_node]
	current_id = start_node
	graph_size = ticker
	
	nav_agent = NavigationAgent2D.new()
	nav_agent.avoidance_enabled = true
	nav_agent.radius = 0.1
	nav_agent.set_navigation_map(get_world_2d().get_navigation_map())
	
	sprite.animation = "walk"
	sprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_node("/root/Game").run_game:
		return
	if move:
		if !chasing:
			if (a_star.get_point_position(current_id) - kb.global_position).length() < 5:
				current_id += 1
				if current_id >= len(path):
					current_id = 0
			var mv = (a_star.get_point_position(current_id) - kb.global_position).normalized()
			kb.velocity = mv * speed
			
			kb.move_and_slide()
		else:
			nav_agent.set_target_position(get_node("/root/Game/Player/PlayerBody").global_position)
			var path = (NavigationServer2D.map_get_path(get_world_2d().get_navigation_map(), kb.global_position, get_node("/root/Game/Player/PlayerBody").global_position, false))
			if len(path) > 2: print(path)
			kb.velocity = (path[1] - kb.global_position).normalized() * (speed)
			kb.move_and_slide()
		#	var desired_dest = get_node("/root/Game/Player/PlayerBody").global_position 
		#	var space_rid = get_world_2d().space
		#	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
		#	var query = PhysicsRayQueryParameters2D.create(position, desired_dest)
		#	query.set_collision_mask(1)
		#	var result = space_state.intersect_ray(query)
		#	if result.colliderim  == null: 
		#		kb.velocity = (desired_dest - kb.global_position).normalized() * (speed/3)
		#		kb.move_and_slide()
		#	elif result.collider == get_node("/root/Game/Player/PlayerBody"):
		#		kb.velocity = (desired_dest - kb.global_position).normalized() * speed
		#		kb.move_and_slide()
		#	else:
		#		kb.velocity = (desired_dest - kb.global_position).normalized() * (speed/3)
		#		kb.move_and_slide()
		if kb.velocity.x < 0 && !caught:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
func _on_radius_area_body_entered(body):
	radius_sprite.animation = "spotted"
	chasing = true
	get_node("Body/AudioStreamPlayer2D").playing = true


func _on_radius_area_body_exited(body):
	radius_sprite.animation = "default"
	chasing = false


func _on_catch_area_body_entered(body):
	var n = busted.instantiate()
	get_node("/root/Game/Player/PlayerBody").add_child(n)
	n.position = Vector2.ZERO
	sprite.animation = "idle"
	sprite.stop()
	get_node("/root/Game/Player").lock_movement = true
	move = false
	caught = true
