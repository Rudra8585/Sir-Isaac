extends Camera2D

@export var transition_time: float = 0.5 
var current_tween: Tween 

func _ready() -> void:
	for camera_switch in get_tree().get_nodes_in_group("cameraSwitch"):
		camera_switch.body_entered.connect(_on_camera_switch_entered.bind(camera_switch))
		
func _on_camera_switch_entered(body: Node2D, room: Area2D):
	if body.name == "Player":
		if current_tween and current_tween.is_valid():
			current_tween.kill()
			
		current_tween = create_tween()
		current_tween.set_trans(Tween.TRANS_CUBIC)
		current_tween.set_ease(Tween.EASE_IN_OUT)
		current_tween.tween_property(self, "global_position", room.global_position, transition_time)
