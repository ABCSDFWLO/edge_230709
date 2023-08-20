extends RigidBody2D

const INITIAL_VELOCITY=8000.0
var a
var player

signal player_attacked()

func fire(angle):
	a=angle
	linear_velocity=Vector2(INITIAL_VELOCITY*cos(angle),INITIAL_VELOCITY*sin(angle))

# Called when the node enters the scene tree for the first time.
func _ready():
	player=get_node("../../Player")
	player_attacked.connect(player.get_damaged)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	linear_velocity=Vector2(0,0)
	sleeping=true
	set_deferred("freeze",true)
	$AnimationPlayer.play("explode")
	if body==player:
		player_attacked.emit()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
