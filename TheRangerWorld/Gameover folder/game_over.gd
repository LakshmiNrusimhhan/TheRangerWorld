extends CanvasLayer


func _on_respawn_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_leave_pressed():
	get_tree().quit()



