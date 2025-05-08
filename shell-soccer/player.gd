extends CharacterBody3D

signal grab(player)
signal shoot
signal drop


@export var speed = 18
@export var max_speed = 18

@export var hit_stun = 1
# force to kick ball with
@export var throw_force = 10
# which team player is on
@export var team = null
@export var look_direction = Vector3.ZERO

var target_velocity = Vector3.ZERO
var direction = Vector3.ZERO
# only ball is grabable
var grabbed_object = null
# slide state
var slide_friction = 1
var can_slide = true
var is_sliding = false
var is_stunned = false
var is_shooting = false

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	# not great implementation, but can't do actions
	# if in the stun state
	if !is_stunned:
		if !is_sliding:
			if grabbed_object != null:
				speed = max_speed / 2.0
			else:
				speed = max_speed
		
		
		# directional movement
		# can only change direction while not sliding
		if (!is_sliding and can_slide):
			direction = Vector3.ZERO
			if Input.is_action_pressed("move_forward"):
				direction.z -= 1
			if Input.is_action_pressed("move_back"):
				direction.z += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_right"):
				direction.x += 1
		
		
		# normalize direction vector
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			$Pivot.basis = Basis.looking_at(direction)
			look_direction = direction
		
		
		# shoot the ball, only if holding it
		if Input.is_action_just_pressed("shoot"):
			if can_slide and !is_stunned:
				if grabbed_object != null:
					shoot.emit()
					#print("shoot")
					grabbed_object = null
		
		
		if !is_sliding:
			target_velocity.x = direction.x * speed
			target_velocity.z = direction.z * speed
		else:
			if speed > 0:
				#$Pivot/SlideHitbox.monitorable = true
				$Pivot/SlideHitbox/CollisionShape3D.disabled = false
				$Pivot/SlideHitbox/MeshInstance3D.show()
				#$Pivot/SlideHitbox/MeshInstance3D.show()
				speed -= slide_friction
				#print(speed)
				#print(direction)
				#slide_friction *= 2
				target_velocity.x = look_direction.x * speed
				target_velocity.z = look_direction.z * speed
			else:
				#$Pivot/SlideHitbox.monitorable = false
				$Pivot/SlideHitbox/CollisionShape3D.disabled = true
				$Pivot/SlideHitbox/MeshInstance3D.hide()
				#$Pivot/SlideHitbox/MeshInstance3D.hide()
				is_sliding = false
				#print("slide end")
				speed = max_speed
				direction = Vector3.ZERO
				#target_velocity.x = 0
				#target_velocity.z = 0
		
		
		
		# slide tackle or pass ball
		if Input.is_action_just_pressed("slide"):
			if !is_sliding and can_slide and !is_stunned:
				if grabbed_object == null:
					is_sliding = true
					can_slide = false
					$SlideCooldown.start()
					#print("slide start")
					speed = max_speed * 2
		
		
		
		velocity = target_velocity
		
		move_and_slide()


func _on_ball_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball"):
		# ball must not be held by anyone before being grabbed
		if body.held_by == null:
			if grabbed_object == null:
				grabbed_object = body
			grab.emit(self)
			#print("grabbed")


func _on_slide_cooldown_timeout() -> void:
	#print("Time")
	can_slide = true

func _on_stun_timer_timeout() -> void:
	#print("Unstunned")
	is_stunned = false
	speed = max_speed


func _on_hurt_box_area_entered(hitbox: Area3D) -> void:
	# don't trigger if hit by self
	if hitbox != $Pivot/SlideHitbox:
		# only hit if not already hit and holding ball
		if !is_sliding and grabbed_object != null:
			drop.emit()
			#print("		HIT")
			is_stunned = true
			#print("Grabbed: ", grabbed_object)
			speed = 0
			$StunTimer.start()
			grabbed_object = null
