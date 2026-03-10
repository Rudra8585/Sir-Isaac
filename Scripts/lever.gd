extends Area2D

@export var target_mech: Node2D 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var silhouette: Sprite2D = $Sprite2D 
@onready var lever_sound: AudioStreamPlayer2D = $LeverSound

var is_pulled: bool = false
var player_in_range: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		silhouette.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		silhouette.visible = false

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("activate") and not is_transitioning:
		toggle_lever()

func toggle_lever() -> void:
	lever_sound.play()
	is_transitioning = true 
	is_pulled = !is_pulled
	
	if silhouette:
		silhouette.hide()
	
	if is_pulled:
		animated_sprite.play("lever")
		if target_mech and target_mech.has_method("toggle_gate"):
			target_mech.toggle_gate()
		elif target_mech and target_mech.has_method("raise_plat"):
			target_mech.raise_plat()
	else:
		animated_sprite.play_backwards("lever")
		if target_mech and target_mech.has_method("toggle_gate"):
			target_mech.toggle_gate()
		elif target_mech and target_mech.has_method("drop_plat"):
			target_mech.drop_plat()
			
	silhouette.flip_h = is_pulled
	await get_tree().create_timer(1.0).timeout
	
	if player_in_range:
		silhouette.show()
		
	is_transitioning = false
