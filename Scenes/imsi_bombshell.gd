extends Node2D

var bomb=preload("res://Scenes/Enemies/Infantry/BombShell_Infantry_C.tscn")
var angle=0
var gravity=ProjectSettings.get_setting("physics/2d/default_gravity")

const V=8000.0
func _input(event):
	if event.is_action("action1"):
		var tempbomb=bomb.instantiate()
		tempbomb.fire(angle)
		add_child(tempbomb)
		if angle>-PI/2:
			angle-=0.01
		elif angle<-PI/2:
			angle=0
	if event.is_action_pressed("action2"):
		var tempbomb=bomb.instantiate()
		tempbomb.fire(calc($target.position))
		add_child(tempbomb)


func calc(a:Vector2):
	var g=gravity
	var w0=a.x
	var th0=PI/2-asin(g*w0/(V*V))/2
	var h0=0
	var dh0=h0-a.y
	var dw0=dh0/tan(th0)
	var w1=w0+dw0
	var th1=PI/2-asin(g*w1/(V*V))/2
	var t0=2*V/g
	var t1=t0*cos(th0)/cos(th1)
	var h1=V*t1-0.5*g*t1*t1
	var dh1=h1-a.y
	var dw1=dh1/tan(th1)
	var w2=w1+dw1
	var th2=PI/2-asin(g*w2/(V*V))/2
	var t2=t1*cos(th1)/cos(th2)
	var h2=V*t2-0.5*g*t2*t2
	var dh2=h2-a.y
	var dw2=dh2/tan(th2)
	var w3=w2+dw2
	var th3=PI/2-asin(g*w3/(V*V))/2
	print_debug(h0," ",h1," ",h2," ")
	print_debug(w0," ",w1," ",w2," ",w3)
	print_debug(th0/PI*180," ",th1/PI*180," ",th2/PI*180," ",th3/PI*180)
	return -th3
