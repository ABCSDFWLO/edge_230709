extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -5000.0

const BLEND_X = 50
const BLEND_Y = 2500
const BLEND_Y_DELTA = 1500

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player : CharacterBody2D

var player_distance : Vector2

enum {
	IDLE0,
	MOVE_LEFT,
	MOVE_RIGHT,
	ATTACK_LEFT_PREDELAY,
	ATTACK_LEFT,
	ATTACK_LEFT_PRODELAY,
	ATTACK_RIGHT_PREDELAY,
	ATTACK_RIGHT,
	ATTACK_RIGHT_PRODELAY
}
enum {
	IDLE1,
	JUMP
}
var action0 :int
var action1 :int

var Sensor_right_floor

var anim_tree : AnimationTree
var anim_player : AnimationPlayer
#var sensor_left : Area2D
#var sensor_right : Area2D
#var sensor_upper : Area2D
#var sensor_left_floor : Area2D
#var sensor_right_floor : Area2D

var s_l:bool
var s_r:bool
var s_u:bool
var s_l_f:bool
var s_r_f:bool

func _ready():
	player=get_node("/root/Node2D/Player")
	anim_tree=$AnimationTree
	anim_player=$AnimationPlayer
	#sensor_left=$Sensor_left
	#sensor_right=$Sensor_right
	#sensor_upper=$Sensor_upper
	#sensor_left_floor=$Sensor_left_floor
	#sensor_right_floor=$Sensor_right_floor

func _process(delta):
	#print_debug(sensor_left_floor.has_overlapping_areas(),sensor_left_floor.has_overlapping_bodies())
	control()
	animation()
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if action1 == JUMP and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if action0 == MOVE_LEFT :
		velocity.x = -SPEED
	elif action0 == MOVE_RIGHT:
		velocity.x = SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

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
	if action0==IDLE0:
		action0=MOVE_LEFT
	if action0==MOVE_LEFT and (not s_l_f or is_on_wall()):
		action0=MOVE_RIGHT
	elif action0==MOVE_RIGHT and (not s_r_f or is_on_wall()):
		action0=MOVE_LEFT
	pass


func _on_sensor_right_floor_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		s_r_f=true


func _on_sensor_left_floor_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		s_l_f=true
