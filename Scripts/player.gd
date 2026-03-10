extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var max_chain_length: float = 96.0 
@export var chain_texture: Texture2D 

var tethered_block: CharacterBody2D = null
var chain_line: Line2D 
var was_in_air: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tether_sound: AudioStreamPlayer = $TetherSound
@onready var gauntlet_sound: AudioStreamPlayer = $GauntletSound
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound

func _ready() -> void:
	chain_line = Line2D.new()
	add_child(chain_line)
	chain_line.width = 8.0 
	chain_line.show_behind_parent = true 
	
	if chain_texture:
		chain_line.texture = chain_texture
		chain_line.texture_mode = Line2D.LINE_TEXTURE_TILE
		chain_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	chain_line.hide()

func _physics_process(delta: float) -> void:
	if is_on_floor() and was_in_air:
		if land_sound:
			land_sound.pitch_scale = randf_range(0.9, 1.1)
			land_sound.play()
	
	was_in_air = not is_on_floor()

	if tethered_block:
		handle_tethered_physics(delta)
	else:
		handle_normal_physics(delta)

func handle_normal_physics(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_sound:
			jump_sound.pitch_scale = randf_range(0.95, 1.05)
			jump_sound.play()

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animations(direction)
	move_and_slide()

func handle_tethered_physics(delta: float) -> void:
	if chain_line:
		chain_line.clear_points()
		var p0 = Vector2.ZERO 
		var p2 = to_local(tethered_block.global_position) 
		var distance = p0.distance_to(p2)
		var slack = max(0.0, max_chain_length - distance)
		var sag_multiplier = 0.8 
		var p1 = (p0 + p2) / 2.0 + Vector2(0, slack * sag_multiplier)
		
		var segments = 10
		for i in range(segments + 1):
			var t = i / float(segments)
			var q0 = p0.lerp(p1, t)
			var q1 = p1.lerp(p2, t)
			var curve_point = q0.lerp(q1, t)
			chain_line.add_point(curve_point)
		
	var direction := 0.0
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			animated_sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		if jump_sound:
			jump_sound.play()
			
		var facing = -1.0 if animated_sprite.flip_h else 1.0
		velocity.x = facing * SPEED 
		toggle_tether(tethered_block) 
		return 

	var radius_vec = global_position - tethered_block.global_position
	var distance = radius_vec.length()
	
	if distance >= max_chain_length:
		var normal = radius_vec.normalized()
		global_position = tethered_block.global_position + (normal * max_chain_length)
		var block_vel = Vector2.ZERO
		if "velocity" in tethered_block:
			block_vel = tethered_block.velocity
		var relative_vel = velocity - block_vel
		if relative_vel.dot(normal) > 0: 
			relative_vel = relative_vel.slide(normal)
		velocity = block_vel + relative_vel

	update_animations(direction) 
	move_and_slide()

func toggle_tether(block: CharacterBody2D) -> void:
	if tethered_block == block:
		tethered_block = null
		if chain_line:
			chain_line.hide()
		if tether_sound:
			tether_sound.play()
	else:
		if global_position.distance_to(block.global_position) <= max_chain_length:
			tethered_block = block
			if chain_line:
				chain_line.show()
			if tether_sound:
				tether_sound.play()

func update_animations(direction: float):
	if Input.is_action_just_pressed("useGauntlet"):
		animated_sprite.play("use_gauntlet")
		if gauntlet_sound:
			gauntlet_sound.play()
		return

	if not is_on_floor():
		if tethered_block:
			animated_sprite.play("falling")
		else:
			if velocity.y < 0:
				animated_sprite.play("jump_start")
			else:
				animated_sprite.play("falling")
	else:
		if animated_sprite.animation == "land" and animated_sprite.is_playing():
			return
		if direction != 0:
			animated_sprite.play("run")
		else:
			if animated_sprite.animation == "use_gauntlet" and animated_sprite.is_playing():
				return
			animated_sprite.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite.animation == "run":
		if animated_sprite.frame == 0 or animated_sprite.frame == 4:
			footstep_sound.pitch_scale = randf_range(0.8, 1.2)
			footstep_sound.play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
