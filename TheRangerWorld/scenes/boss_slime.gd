extends CharacterBody2D

var speed = 50
 
var health = 500
const max_health = 500
const damage = 50
var dead = false
var player_in_area = false
var player

@onready var slime = $slime_collectable
@export var itemRes: InvItem

func boss_slime_damaging():
	pass

func _ready():
	dead = false

func _physics_process(delta):
	if !dead:
		$detection_area/CollisionShape2D.disabled = false
		if player_in_area:
			position += (player.position - position) / speed
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
	if dead:
		$detection_area/CollisionShape2D.disabled = true

func _on_detection_area_body_entered(body):
	print("bigslimm_enter")
	print(body)
	print(body.has_method("player"))
	if body.has_method("player"):
		print("player_in_areafffff")
		player_in_area = true
		player = body
		
func _on_detection_area_body_exited(body):
	print("bigslimm_exit")
	print(body)
	print(body.has_method("player"))
	if body.has_method("player"):
		print("player_out_areafffff")
		player_in_area = false

func _on_hitbox_area_exited(area):
	print("_on_hitbox_area_exited")
	

func _on_hitbox_area_entered(area):
	#print("11111_on_hitbox_area_entered")
	#print(area)
	#print(area.has_method("arrow_damage_boss_slime"))
	#print("1x1x1x1x11")
	if area.has_method("arrow_damage_boss_slime"):
		print("refrfdfr")
		take_damage()

func take_damage():
	health = health - damage
	print(health)
	update_health()
	if health <= 0 and !dead:
		death()
	
func death():
	dead = true
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1).timeout
	drop_slime()
	
	$AnimatedSprite2D.visible = false
	$hitbox/CollisionShape2D.disabled = true
	$detection_area/CollisionShape2D.disabled = true


func drop_slime():
	slime.visible = true
	$slime_collect_area/CollisionShape2D.disabled = false
	slime_collect()
	
func slime_collect():
	await get_tree().create_timer(1.5).timeout
	slime.visible = false
	player.collect(itemRes)
	queue_free()

func _on_slime_collect_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.has_method("player"):
		player = body

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	
	if health >= max_health or health <= 0:
		healthbar.visible = false
	else:
		healthbar.visible = true
	
