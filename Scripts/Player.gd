extends CharacterBody2D


const SPEED = 1500.0
const JUMP_VELOCITY = -5000.0
const EPSILON = 1
const JUMP_ABILITY=2
const DASH_SPEED=5000.0

const BLEND_X = 50
const BLEND_Y = 2500
const BLEND_Y_DELTA = 1500

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped=0
var latest_dir:Vector2i
var is_invincible:=false

var action_slot=[0,1,-1]
var action_playing:String="_"
var is_action_playing:bool=false
var actions:Array=[
	"0_left",
	"0_right",
	"1_left",
	"1_right"
]

const HP_MAX=10
var hp=HP_MAX

signal hp_changed(m,h)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumped=0
		
	if not is_action_playing:
		if Input.is_action_just_pressed("jump") and (is_on_floor() or jumped<JUMP_ABILITY):
			velocity.y = JUMP_VELOCITY
			jumped+=1
			
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif action_playing=="1_left":
		velocity.x=-DASH_SPEED
	elif action_playing=="1_right":
		velocity.x=DASH_SPEED
	else:
		velocity.x=move_toward(velocity.x,0,SPEED*7)
	move_and_slide()

func _process(_delta):
	#print_debug(action_playing,is_action_playing)
	animation()
	if (self.position.y>5000):
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")

func _input(event):
	if event.is_action_pressed("left"):
		latest_dir.x=-1
	elif event.is_action_pressed("right"):
		latest_dir.x=1
	elif event.is_action_pressed("up"):
		latest_dir.y=-1
	elif event.is_action_pressed("down"):
		latest_dir.y=1
	
	if not is_invincible:
		if event.is_action_pressed("action0"):
			if action_slot[0] != -1:
				action_playing=animation_map(action_slot[0])
		elif event.is_action_pressed("action1"):
			if action_slot[1] != -1:
				action_playing=animation_map(action_slot[1])
		elif event.is_action_pressed("action2"):
			if action_slot[2] != -1:
				action_playing=animation_map(action_slot[2])

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
		$AnimationTree.set("parameters/blend_fall/blend_amount",clamp((velocity.y-BLEND_Y_DELTA)/BLEND_Y,0,1))
		$AnimationTree.set("parameters/blend_jump/blend_amount",0)
	else:
		$AnimationTree.set("parameters/blend_jump/blend_amount",clamp((-velocity.y-BLEND_Y_DELTA)/BLEND_Y,0,1))
		$AnimationTree.set("parameters/blend_fall/blend_amount",0)

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
		1:
			if (latest_dir.x<0):
				return "1_left"
			else:
				return "1_right"
		_:
			return "_"

func _on_animation_tree_animation_finished(anim_name:String):
	if anim_name=="damaged":
		action_playing="_"
		is_invincible=false
	else:
		var n=anim_name.get_slice("action",1)
		if actions.has(n):
			action_playing="_"
			is_action_playing=false
		else:
			print_debug("animation played doesn't exist, check animation's name")

func get_damaged():
	if not is_invincible:	
		hp-=1
		hp_changed.emit(HP_MAX,hp)
		if (hp<=0):
			get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
		$AnimationTree.set("parameters/damaged/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		$AnimationTree.set("parameters/"+action_playing+"/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		action_playing="damaged"
		is_action_playing=false
		is_invincible=true

func set_invincible(b:bool):
	is_invincible=b

#freakin attack collision checks
#action0_area
func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.get_priority()>1: #shields have priority of over 1 (usually, 5?)
		$AnimationTree.set("parameters/"+action_playing+"/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		action_playing="_"
		is_action_playing=false
#action0_body
func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	body.get_damaged()
