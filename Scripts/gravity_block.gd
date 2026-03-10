extends CharacterBody2D

@export var gravity_acceleration: float = 1200.0
@export var terminal_velocity: float = 800.0
@export var grid_size: float = 16.0

@onready var block_sprite: Sprite2D = $LitSprite2D 
@onready var hover_indicator: Marker2D = $UIPivot
@onready var gravity_sound: AudioStreamPlayer = $GravitySound
@onready var impact_sound: AudioStreamPlayer2D = $ImpactSound

var is_hovered: bool = false
var current_direction: Vector2 = Vector2.DOWN
var current_speed: float = 0.0
var active = false 
var was_supported = false
var can_play_impact: bool = true 

func _ready() -> void:
	add_to_group("block")
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if hover_indicator:
		hover_indicator.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gravityDown"): 
		for block in get_tree().get_nodes_in_group("block"):
			if block.was_supported: 
				block.reset_to_default_gravity()
	

	if not is_hovered: return
	
	if was_supported and event is InputEventMouseButton and event.pressed:
		if event.is_action_pressed("useGauntlet"):
			var click_pos = get_local_mouse_position()
			if abs(click_pos.y) > abs(click_pos.x):
				if click_pos.y < 0: change_gravity(Vector2.UP)
				else: reset_to_default_gravity()
			else:
				if click_pos.x < 0: change_gravity(Vector2.LEFT)
				else: change_gravity(Vector2.RIGHT)
			if hover_indicator: hover_indicator.hide()
				
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("toggle_tether"):
				player.toggle_tether(self)

func _process(delta: float) -> void:
	if is_hovered and hover_indicator:
		var mouse_pos = get_local_mouse_position()
		
		# Restored Rotation Logic
		if abs(mouse_pos.y) > abs(mouse_pos.x):
			if mouse_pos.y < 0:
				hover_indicator.rotation_degrees = -90 # UP
			else:
				hover_indicator.rotation_degrees = 90  # DOWN
		else:
			if mouse_pos.x < 0:
				hover_indicator.rotation_degrees = 180 # LEFT
			else:
				hover_indicator.rotation_degrees = 0   # RIGHT

func _physics_process(delta: float) -> void:
	if active:
		$UnlitSprite2D.visible = false
		$LitSprite2D.visible = true
		current_speed += gravity_acceleration * delta
		current_speed = min(current_speed, terminal_velocity)
		velocity = current_direction * current_speed
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			if can_play_impact and current_speed > 100.0:
				play_impact_sound()
				can_play_impact = false
			was_supported = true
			current_speed = 0.0
			snap_to_grid()
	else:
		$UnlitSprite2D.visible = true
		$LitSprite2D.visible = false
		current_direction = Vector2.DOWN 
		current_speed += gravity_acceleration * delta
		current_speed = min(current_speed, terminal_velocity)
		velocity = Vector2(0, current_speed)
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			if not was_supported and current_speed > 100.0:
				play_impact_sound()
				snap_to_grid()
			current_speed = 0.0
			was_supported = true
		else:
			was_supported = false

func reset_to_default_gravity() -> void:
	if active and gravity_sound:
		gravity_sound.play()
	active = false
	was_supported = false 
	can_play_impact = true
	current_speed = 0.0
	current_direction = Vector2.DOWN

func play_impact_sound() -> void:
	if impact_sound:
		impact_sound.pitch_scale = randf_range(0.85, 1.15)
		impact_sound.play()

func change_gravity(new_direction: Vector2) -> void:
	if was_supported:
		if gravity_sound:
			gravity_sound.play()
		can_play_impact = true 
		current_direction = new_direction.normalized()
		active = true
		current_speed = 0.0
		was_supported = false

func snap_to_grid() -> void:
	var snapped_pos = global_position.snapped(Vector2(grid_size, grid_size))
	global_position = snapped_pos

func _on_mouse_entered() -> void:
	is_hovered = true
	if hover_indicator: hover_indicator.show()

func _on_mouse_exited() -> void:
	is_hovered = false
	if hover_indicator: hover_indicator.hide()
