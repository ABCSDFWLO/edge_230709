extends CanvasLayer



func _on_player_hp_changed(m,h):
	var ob = get_node("Control/TextureRect/hpbar")
	ob.size.y=h*138/m
