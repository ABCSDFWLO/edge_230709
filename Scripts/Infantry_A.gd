extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -5000.0

const BLEND_X = 50
const BLEND_Y = 2500
const BLEND_Y_DELTA = 1500

const ATTACKABLE_RANGE = 300

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var anim_tree : AnimationTree
var anim_player : AnimationPlayer
var sensor_left_floor : Area2D
var sensor_right_floor : Area2D
var particle_damaged : CPUParticles2D
var player : CharacterBody2D

var senses = {
	"left"=false,
	"right"=false,
	"upper"=false,
	"left_floor"=false,
	"right_floor"=false,
	"action0_left"=false,
	"action0_right"=false
}
var actions = {
	"x_dir"=0, # -1:left / 0:idle / 1:right
	"action0"=0, # -1:left / 0:idle / 1:right
}

func _process(_delta):
	player=get_node("/root/Node2D/Player")
	anim_tree = $AnimationTree
	anim_player=$anim_player
	particle_damaged=$CPUParticles2D

func _physics_process(delta):
	senses["left_floor"]=true if sensor_left_floor.has_overlapping_bodies() and sensor_left_floor.get_overlapping_bodies()[0] is TileMap else false
	senses["right_floor"]=true if sensor_right_floor.has_overlapping_bodies() and sensor_right_floor.get_overlapping_bodies()[0] is TileMap else false
	if not is_on_floor():
		velocity.y += gravity * delta
	if senses["upper"] and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if actions["x_dir"] == 0 :
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = actions["x_dir"] * SPEED
	move_and_slide()

func animation():
	anim_tree.set("parameters/blend_move_dir/blend_amount",clamp(velocity.x/BLEND_X,-0.5,0.5)+0.5)
	anim_tree.set("parameters/blend_move/blend_amount",clamp(abs(velocity.x/BLEND_X),0,1))
	if actions["action0"]==-1:
		anim_tree.set("parameters/blend_attack_dir/blend_amount",0)
	elif actions["action0"]==1:
		anim_tree.set("parameters/blend_attack_dir/blend_amount",1)
	if (velocity.y<BLEND_Y_DELTA and velocity.y>-BLEND_Y_DELTA):
		anim_tree.set("parameters/blend_fall/blend_amount",0)
		anim_tree.set("parameters/blend_jump/blend_amount",0)
	elif (velocity.y>0):
		anim_tree.set("parameters/blend_fall/blend_amount",clamp(velocity.y/BLEND_Y,0,1))
		anim_tree.set("parameters/blend_jump/blend_amount",0)
	else:
		anim_tree.set("parameters/blend_jump/blend_amount",clamp(-velocity.y/BLEND_Y,0,1))
		anim_tree.set("parameters/blend_fall/blend_amount",0)

func animation_shot_attack():
	anim_tree.set("parameters/shot_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func control():
	
	
	
	pass
func _on_atk_0_body_entered(body):
	print_debug("아야")
