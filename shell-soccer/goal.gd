extends CharacterBody3D

signal blasted

# need to know which side goal is on
# to update correct side score accordingly
@export var team = null


func _initialize(start_position, team_on):
	position = start_position
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_ball_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball"):
		blasted.emit()
		queue_free()
