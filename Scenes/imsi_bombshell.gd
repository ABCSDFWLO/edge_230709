extends Node2D

var bomb=preload("res://Scenes/Enemies/Infantry/BombShell_Infantry_C.tscn")
var angle=0
var gravity=ProjectSettings.get_setting("physics/2d/default_gravity")
func _input(event):
	if event.is_action("action1"):
		var tempbomb=bomb.instantiate()
		tempbomb.fire(angle)
		add_child(tempbomb)
		if angle>-PI/2:
			angle-=0.01
		elif angle<-PI/2:
			angle=0
	if event.is_action("action2"):
		$target.position


func calc(a:Vector2):
	var w
	var dh
	var r
	w=a.x
	r=asin(gravity*w/(8000*8000))/2
	
	w=w-dh/tan(r)
	
