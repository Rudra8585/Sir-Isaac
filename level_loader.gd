extends Area2D

@export_file("*.tscn") var target_level: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if target_level == "":
			print("Warning: No target level assigned to this portal!")
			return

		get_tree().change_scene_to_file(target_level)
