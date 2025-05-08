extends CharacterBody3D


@export var speed = 30
# player that is holding ball
@export var held_by = null
# need to know which team player is on
# to pass and whether slide stuns
@export var team = null

var direction = Vector3.ZERO

var target_velocity = Vector3.ZERO
var bounce_strength = 0.5


func _physics_process(delta: float) -> void:
	#print("Ball Holder ", held_by)
	if held_by != null:
		if held_by.grabbed_object != self:
			#print("			ENSURE")
			held_by = null
			direction = Vector3.ZERO
			target_velocity = Vector3.ZERO
			velocity = Vector3.ZERO
		elif held_by.look_direction != Vector3.ZERO:
			target_velocity = held_by.look_direction.normalized() * speed
			position = held_by.position + (held_by.look_direction.normalized() / 2)
			
			#print("ping")
			direction = held_by.look_direction.normalized()
			$Pivot.basis = Basis.looking_at(direction)
		
	else:
		#print("Ball Velocity: ", velocity)
		#print("Ball Direction: ", direction)
		
		direction = velocity.normalized()
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			$Pivot.basis = Basis.looking_at(direction)
			
		
		# multiply by delta as velocity is updated every frame
		#print(direction)
		#print("	TVELOCITY: ", target_velocity)
		velocity = target_velocity * delta
		
		var collision = move_and_collide(velocity)
		if collision:
			# don't need to multiply by delta as this occurs
			# only once on a collision
			target_velocity = velocity.bounce(collision.get_normal()).normalized() * speed * bounce_strength

# receiving signal from player, with player as parameter
func _on_player_grab(player: Node3D) -> void:
	held_by = player
	#print("BALL GET GRAB: ", held_by)
	target_velocity = held_by.look_direction.normalized() * speed
	position = held_by.position + held_by.look_direction.normalized()
	
	direction = held_by.look_direction.normalized()
	$Pivot.basis = Basis.looking_at(direction)


func _on_player_shoot() -> void:
	held_by = null


func _on_player_drop() -> void:
	#print("\n\n\n drop")
	#print("dropped by: ", held_by)
	held_by = null
	direction = Vector3.ZERO
	target_velocity = Vector3.ZERO
	velocity = target_velocity
