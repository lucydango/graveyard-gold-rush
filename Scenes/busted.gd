extends Control

var ticker = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Game").run_game = false
	# yeah
	get_node("/root/Game/Player/PlayerBody/PlayerCam/PlayerHUD/TimerContainer").visible = false
	get_node("/root/Game/Player/PlayerBody/PlayerCam/PlayerHUD/PanelContainer").visible = false
	get_node("/root/Game/Player/PlayerBody/PlayerCam/PlayerHUD/TextureRect").visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ticker -= delta
	if ticker > 0: 
		get_node("/root/Game/Lights/Fog/CanvasModulate").color.a -= 0.4 * delta
	if ticker < 0:
		get_node("PanelContainer2").visible = true
	if ticker < -0.5: 
		get_node("Label2").visible = true
		if snapped(ticker, 0) % 2 == 0:
			get_node("Label2").visible = false
	if Input.is_action_just_pressed("detect"):
		get_tree().reload_current_scene()
	get_node("PanelContainer2/Label").text = str(get_node("/root/Game/Player/PlayerBody/PlayerCam/PlayerHUD").points)
