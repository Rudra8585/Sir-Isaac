extends StaticBody2D

@export var open_at_start: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var gate_open_sound: AudioStreamPlayer2D = $GateOpenSound
@onready var gate_close_sound: AudioStreamPlayer2D = $GateCloseSound

var is_open: bool = false

func _ready() -> void:
	if open_at_start:
		open_gate()

func toggle_gate() -> void:
	is_open = !is_open
	
	if is_open:
		animated_sprite.play("gate")
		gate_open_sound.play()
		collision_shape.set_deferred("disabled", true)
		
	else:
		animated_sprite.play_backwards("gate")
		gate_close_sound.play()
		collision_shape.set_deferred("disabled", false)

func open_gate() -> void:
	if not is_open:
		toggle_gate()

func close_gate() -> void:
	if is_open:
		toggle_gate()
