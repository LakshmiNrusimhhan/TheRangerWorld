extends StaticBody2D



func _on_area_2d_body_entered(body):
	get_tree().change_scene_to_file("res://Gameover folder/you_won!.tscn")
