extends Node2D

var bomb=preload("res://Scenes/Enemies/Infantry/BombShell_Infantry_C.tscn")
var angle=0
var gravity=ProjectSettings.get_setting("physics/2d/default_gravity")
const ACCURACY=100

const V=8000.0
var player : CharacterBody2D


func _ready():
	pass#player=get_node("/root/Node2D/Player")

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
		#tempbomb.fire(calc(player.position-self.position))
		tempbomb.fire(calc($target.position))
		add_child(tempbomb)


func calc(a:Vector2):
	var g=gravity
	var size:int=round(V*V*1.212/g/ACCURACY)
	var y={}
	var map=[]
	for i in size:
		var th=(PI/4)*(1+float(i)/size)
		y[i]=(a.x*tan(th)-((g*a.x*a.x)/(2*V*V*cos(th)*cos(th))))
		map.append(i)
	map.sort_custom(func(a,b):return y[a]<y[b])
	var s:int=0
	var e:int=size-1
	var m:int=0
	while(s<=e):
		m=(s+e)/2
		if(e-s<=1):
			print_debug(y)
			print_debug(map[m]," ",y[map[m]])
			var d0=abs(y[map[s]]+a.y)
			var d1=abs(y[map[e]]+a.y)
			return -(PI/4)*(1+float(map[s])/size) if d0<d1 else -(PI/4)*(1+float(map[e])/size)
		elif (y[map[m]]<-a.y):
			s=m
		elif (-a.y<y[map[m]]):
			e=m

func calc0(a:Vector2):
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
