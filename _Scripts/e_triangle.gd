extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const BLEND_X = 50
const BLEND_Y = 2500
const BLEND_Y_DELTA = 1500

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player : CharacterBody2D

var state = {
	#거리 / 방향 / 
}
var flag = {
	#세세한 행동의 제한 ex) action중 이동 제한
}

var anim_tree : AnimationTree
var anim_player : AnimationPlayer
var sensor_left : Area2D
var sensor_right : Area2D
var sensor_upper : Area2D
var sensor_left_floor : RayCast2D
var sensor_right_floor : RayCast2D


func _ready():
	player=get_node("/root/Node2D/Player")
	anim_tree=$AnimationTree
	anim_player=$AnimationPlayer
	sensor_left=$Sensor_left
	sensor_right=$Sensor_right
	sensor_upper=$Sensor_upper
	sensor_left_floor=$Sensor_left_floor
	sensor_right_floor=$Sensor_right_floor

func _process(delta):
	print_debug(sensor_left_floor.get_collider(),sensor_right_floor.get_collider())
	print_debug(sensor_left_floor.is_colliding())

func _physics_process(delta):
	pass

func animation():
	anim_tree.set("parameters/blend_move_dir/blend_amount",clamp(velocity.x/BLEND_X,-0.5,0.5)+0.5)
	anim_tree.set("parameters/blend_move/blend_amount",clamp(abs(velocity.x/BLEND_X),0,1))
	if (velocity.y<BLEND_Y_DELTA and velocity.y>-BLEND_Y_DELTA):
		anim_tree.set("parameters/blend_fall/blend_amount",0)
		anim_tree.set("parameters/blend_jump/blend_amount",0)
	elif (velocity.y>0):
		anim_tree.set("parameters/blend_fall/blend_amount",clamp(velocity.y/BLEND_Y,0,1))
		anim_tree.set("parameters/blend_jump/blend_amount",0)
	else:
		anim_tree.set("parameters/blend_jump/blend_amount",clamp(-velocity.y/BLEND_Y,0,1))
		anim_tree.set("parameters/blend_fall/blend_amount",0)

func control():
	pass
	
func control_physics(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
