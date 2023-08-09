extends Node

var flag=0

func _process(delta):
	if Input.get_action_strength("action0")>0.5:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
