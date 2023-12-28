extends CharacterBody2D

const max_health = 100
var speed = 20
var health = 100
var slime_inattack_range = false
var slime_attack_cooldown = true
var player_alive = true
var player_state

@export var inv: Inv 

var bow_equiped = false
var bow_cooldown = true
var arrow = preload("res://scenes/arrow.tscn")
var mouse_loc_from_player = null

func _process(delta):
	slime_attack()
	update_health()

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	mouse_loc_from_player = get_global_mouse_position()
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction * speed 
	move_and_slide()
	
	if Input.is_action_just_pressed("fire"):
		if bow_equiped:
			bow_equiped = false
		else:
			bow_equiped = true
	
	var mouse_pos = get_global_mouse_position()
	$Marker2D.look_at(mouse_pos)
	
	if Input.is_action_just_pressed("left_mouse") and bow_equiped and bow_cooldown:
		bow_cooldown = false
		var arrow_instance = arrow.instantiate()
		arrow_instance.rotation = $Marker2D.rotation
		arrow_instance.global_position = $Marker2D.global_position
		add_child(arrow_instance)
		
		await get_tree().create_timer(0.4).timeout
		bow_cooldown = true
	
	play_anim(direction)
	
	if health <= 0:
		player_alive = false
		health = 0
		print("player dead")
		$AnimatedSprite2D.play("death")
		hide()
		get_tree().change_scene_to_file("res://Gameover folder/game_over.tscn")
		$CollisionShape2D.set_deferred("disabled",true)

func play_anim(dir):
	if !bow_equiped:
		#print("bow not equipped")
		speed = 100
		if player_state == "idle":
			$AnimatedSprite2D.play("idle")
		if player_state == "walking":
			if dir.y == -1:
				$AnimatedSprite2D.play("n-walk")
			if dir.x == 1:
				$AnimatedSprite2D.play("e-walk")
			if dir.y == 1:
				$AnimatedSprite2D.play("s-walk")
			if dir.x == -1:
				$AnimatedSprite2D.play("w-walk")
		
			if dir.x > 0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("ne-walk")
			if dir.x > 0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("se-walk")
			if dir.x < -0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("sw-walk")
			if dir.x < -0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("nw-walk")
	if bow_equiped:
		#print("bow equipped")
		speed = 0
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.x <= 25 and mouse_loc_from_player.y < 0:
			$AnimatedSprite2D.play("n-attack")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x > 0:
			$AnimatedSprite2D.play("e-attack")
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.y > 0:
			$AnimatedSprite2D.play("s-attack")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x < 0:
			$AnimatedSprite2D.play("w-attack")
			
		if mouse_loc_from_player.x >= 25 and mouse_loc_from_player.y <= -25:
			$AnimatedSprite2D.play("ne-attack")
		if mouse_loc_from_player.x >= 0.5 and mouse_loc_from_player.y >= 25:
			$AnimatedSprite2D.play("se-attack")
		if mouse_loc_from_player.x <= 0.5 and mouse_loc_from_player.y >= 25:
			$AnimatedSprite2D.play("sw-attack")
		if mouse_loc_from_player.x <= -25 and mouse_loc_from_player.y <= -25:
			$AnimatedSprite2D.play("nw-attack")
func player():
	pass
	
func collect(item):
	inv.insert(item)

func _on_hitbox_area_body_entered(body):
	print("_on_hitbox_area_body_entered")
	print(body)
	if body.has_method("slime_damaging") or body.has_method("boss_slime_damaging"):
		print("entered")
		slime_inattack_range = true


func _on_hitbox_area_body_exited(body):
	print("_on_hitbox_area_body_exited")
	if body.has_method("slime_damaging") or body.has_method("boss_slime_damaging"):
		print("exited")
		slime_inattack_range = false

func slime_attack():
	if slime_inattack_range and slime_attack_cooldown == true:
		health = health - 15
		slime_attack_cooldown = false
		$attack_cooldown.start()
		print("slime_attack")
		print(health)


func _on_attack_cooldown_timeout():
	slime_attack_cooldown = true

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regen_timer_timeout():
	if health < max_health:
		health = health + 10
	if health > max_health:
		health = max_health
	if health <= 0:
		health = 0
