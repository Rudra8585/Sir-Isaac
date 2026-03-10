extends Node2D

@export var drop_distance: float = 128.0 
@export var passive_distance: float = 50
@export var travel_duration: float = 2.0 

@onready var platform: AnimatableBody2D = $platform
@onready var pulley: Sprite2D = $top
@onready var rope: TextureRect = $rope

var top_y: float
var bottom_y: float
var active_tween: Tween

func _ready() -> void:
	top_y = platform.position.y + passive_distance
	
	bottom_y = top_y + drop_distance
	

	platform.position.y = bottom_y
	
	rope.position.x = pulley.position.x - (rope.size.x / 2.0)
	rope.position.y = pulley.position.y

func _process(_delta: float) -> void:
	var distance = platform.position.y - pulley.position.y
	
	rope.size.y = distance

func raise_plat() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.tween_property(platform, "position:y", top_y, travel_duration)

func drop_plat() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.tween_property(platform, "position:y", bottom_y, travel_duration)
