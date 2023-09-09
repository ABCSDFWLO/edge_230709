extends CPUParticles2D



func _on_ready():
	$Timer.start()


func _on_timer_timeout():
	queue_free()
