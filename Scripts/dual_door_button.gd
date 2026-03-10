extends Area2D


@export var target_mech1: Node2D 
@export var target_mech2: Node2D 

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
	
	if target_mech1 and target_mech1.has_method("open_gate"):
		target_mech1.toggle_gate()
	elif target_mech1 and target_mech1.has_method("raise_plat"):
			target_mech1.raise_plat()
			
	if target_mech2 and target_mech2.has_method("open_gate"):
		target_mech2.toggle_gate()
	elif target_mech2 and target_mech2.has_method("raise_plat"):
			target_mech2.raise_plat()


func spring_up() -> void:
	sprite.position.y -= 1
	
	if target_mech1 and target_mech1.has_method("close_gate"):
		target_mech1.toggle_gate()
	elif target_mech1 and target_mech1.has_method("drop_plat"):
			target_mech1.drop_plat()
	
	if target_mech2 and target_mech2.has_method("close_gate"):
		target_mech2.toggle_gate()
	elif target_mech2 and target_mech2.has_method("drop_plat"):
			target_mech2.drop_plat()
