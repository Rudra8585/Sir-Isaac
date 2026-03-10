extends Area2D


@export var target_mech: Node2D 

@onready var sprite: Sprite2D = $Sprite2D

var entities_on_button: int = 0 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("block"):
		entities_on_button += 1
		
		if entities_on_button == 1:
			press_down()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("block"):
		entities_on_button -= 1
		
		if entities_on_button == 0:
			spring_up()

func press_down() -> void:
	sprite.position.y += 1 
	
	if target_mech and target_mech.has_method("open_gate"):
		target_mech.toggle_gate()
	elif target_mech and target_mech.has_method("raise_plat"):
			target_mech.raise_plat()

func spring_up() -> void:
	sprite.position.y -= 1
	
	if target_mech and target_mech.has_method("close_gate"):
		target_mech.toggle_gate()
	elif target_mech and target_mech.has_method("drop_plat"):
			target_mech.drop_plat()
