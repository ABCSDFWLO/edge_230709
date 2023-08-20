extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -4000.0

const BLEND_X = 50
const BLEND_Y = 2500
const BLEND_Y_DELTA = 1500

const ATTACKABLE_RANGE = 300

signal player_attacked()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_invincible:bool=false

var player : CharacterBody2D

var latest_dir:Vector2i
var senses = {
	"left"=false,
	"right"=false,
	"upper"=false,
	"left_floor"=false,
	"right_floor"=false,
	"action0_left"=false,
	"action0_right"=false
}
var action_playing:String="_"
var is_action_playing:bool=false
var actions:Array=[
	"0_left",
	"0_right"
]


func _ready():
	player=get_node("../Player")
	player_attacked.connect(player.get_damaged)

func _process(_delta):
	control()
	animation()

func _physics_process(delta):
	senses["left_floor"]=true if $Sensor_left_floor.has_overlapping_bodies() and $Sensor_left_floor.get_overlapping_bodies()[0] is TileMap else false
	senses["right_floor"]=true if $Sensor_right_floor.has_overlapping_bodies() and $Sensor_right_floor.get_overlapping_bodies()[0] is TileMap else false
	if not is_on_floor():
		velocity.y += gravity * delta
	if senses["upper"] and is_on_floor() and not is_action_playing:
		velocity.y = JUMP_VELOCITY
	if latest_dir.x == 0 or not is_action_playing:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = latest_dir.x * SPEED
	move_and_slide()

func animation():
	$AnimationTree.set("parameters/blend_move_dir/blend_amount",clamp(velocity.x/BLEND_X,-0.5,0.5)+0.5)
	$AnimationTree.set("parameters/blend_move/blend_amount",clamp(abs(velocity.x/BLEND_X),0,1))
	
	if actions.has(action_playing) and not is_action_playing:
		$AnimationTree.set("parameters/"+action_playing+"/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_action_playing=true
	if (velocity.y<BLEND_Y_DELTA and velocity.y>-BLEND_Y_DELTA):
		$AnimationTree.set("parameters/blend_fall/blend_amount",0)
		$AnimationTree.set("parameters/blend_jump/blend_amount",0)
	elif (velocity.y>0):
		$AnimationTree.set("parameters/blend_fall/blend_amount",clamp(velocity.y/BLEND_Y,0,1))
		$AnimationTree.set("parameters/blend_jump/blend_amount",0)
	else:
		$AnimationTree.set("parameters/blend_jump/blend_amount",clamp(-velocity.y/BLEND_Y,0,1))
		$AnimationTree.set("parameters/blend_fall/blend_amount",0)

func control():
	if senses["action0_left"] and not is_action_playing and is_on_floor():
		action_playing=animation_map(0)
	elif senses["action0_right"] and not is_action_playing and is_on_floor():
		action_playing=animation_map(0)
	if is_action_playing:
		if senses["left"]:
			latest_dir.x=-1 if senses["left_floor"] else 0
		elif senses["right"]:
			latest_dir.x=1 if senses["right_floor"] else 0
		elif latest_dir.x==-1 and is_on_floor() and (not senses["left_floor"] or is_on_wall()):
			latest_dir.x=1
		elif latest_dir.x==1 and is_on_floor() and (not senses["right_floor"] or is_on_wall()):
			latest_dir.x=-1
		elif latest_dir.x==0:
			latest_dir.x=-1

func animation_map(anim_index:int)->String:
	match (anim_index):
		0:
			if is_on_floor():
				if (latest_dir.x<0):
					return "0_left"
				else:
					return "0_right"
			else:
				return "_"
		_:
			return "_"

func _on_animation_tree_animation_finished(anim_name):
	if anim_name=="attack_left" or anim_name=="attack_right":
		action_playing="_"
		is_action_playing=false
func _on_sensor_left_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["left"]=true
func _on_sensor_left_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["left"]=false
func _on_sensor_right_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["right"]=true
func _on_sensor_right_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["right"]=false
func _on_sensor_upper_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["upper"]=true
func _on_sensor_upper_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["upper"]=false
func _on_sensor_action_0_left_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["action0_left"]=true
func _on_sensor_action_0_left_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["action0_left"]=false
func _on_sensor_action_0_right_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["action0_right"]=true
func _on_sensor_action_0_right_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		senses["action0_right"]=false


func _on_atk_0_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		player_attacked.emit()
func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body==player:
		player_attacked.emit()

func get_damaged():
	if not is_invincible:
		$Timer.start()
		self.modulate=Color(1,1,1,0.5)
		$AnimationTree.set("parameters/shot_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		$CPUParticles2D.restart()
		#hp--
		#시간나면 후딜도 좀 추가할까
		is_action_playing=false
		is_invincible=true
func _on_timer_timeout():
	self.modulate=Color(1,1,1,1)
	is_invincible=false
