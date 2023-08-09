extends RigidBody2D

const INITIAL_VELOCITY=8000.0
var a

func fire(angle):
	a=angle
	linear_velocity=Vector2(INITIAL_VELOCITY*cos(angle),INITIAL_VELOCITY*sin(angle))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var g=ProjectSettings.get_setting("physics/2d/default_gravity")
	var V=INITIAL_VELOCITY
	sleeping=true
	$AnimationPlayer.play("explode")

func _on_animation_player_animation_finished(anim_name):
	queue_free()
