extends Node3D

@export var mouse_sensitivity := 0.005
@export var min_pitch := deg_to_rad(-80)
@export var max_pitch := deg_to_rad(80)

@export var zoom_sensitivity := 0.5
@export var min_zoom := 4.0
@export var max_zoom := 15.0

@onready var camera := $Camera3D

var yaw := 0.0
var pitch := 0.0
var zoom = 10.0
var rotating = false

func _process(delta):
	rotating = Input.is_action_pressed("Camera_Rotate")
	if !Globals.zoom_lockout:
		if Input.is_action_just_pressed("Camera_Zoom_In"):
			zoom -= zoom_sensitivity
		if Input.is_action_just_pressed("Camera_Zoom_Out"):
			zoom += zoom_sensitivity
	zoom = clamp(zoom, min_zoom, max_zoom)
	camera.position.z = zoom
	

func _unhandled_input(event):
	if rotating:
		if event is InputEventMouseMotion:
			yaw -= event.relative.x * mouse_sensitivity
			pitch -= event.relative.y * mouse_sensitivity

			pitch = clamp(pitch, min_pitch, max_pitch)

			rotation.y = yaw
			rotation.x = pitch
