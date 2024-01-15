extends Spatial

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var volcano_position : Vector3 = transform.origin

var attack_position : Vector3

func begin_attack(attack_pos : Vector3) -> void:
	attack_pos.z = 0
	attack_position = attack_pos
	
	animation_player.play("ShootUp")

func play_next_animation(anim_name : String):
	if anim_name == "ShootUp":
		transform.origin = attack_position
		animation_player.play("ShootDown")
	
	elif anim_name == "ShootDown":
		animation_player.play("RESET")
		print("attack ended")
