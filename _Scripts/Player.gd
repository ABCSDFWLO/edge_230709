extends CharacterBody2D


const SPEED = 1500.0
const JUMP_VELOCITY = -4000.0
const EPSILON = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var anim_tree : AnimationTree
var anim_player : AnimationPlayer

func _ready():
	anim_tree=$AnimationTree
	anim_player=$player_anim

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _process(delta):
	anim_tree.set("parameters/blend_move_dir/blend_amount",clamp(velocity.x/50,-0.5,0.5)+0.5)
	anim_tree.set("parameters/blend_move/blend_amount",clamp(abs(velocity.x/50),0,1))
	if (velocity.y>0):
		anim_tree.set("parameters/blend_fall/blend_amount",clamp(velocity.y/5000,0,1))
	else:
		anim_tree.set("parameters/blend_jump/blend_amount",clamp(-velocity.y/5000,0,1))
	if (velocity.y==0):
		anim_tree.set("parameters/blend_fall/blend_amount",0)
		anim_tree.set("parameters/blend_jump/blend_amount",0)
