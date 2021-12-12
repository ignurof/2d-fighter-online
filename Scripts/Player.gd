extends KinematicBody2D

var localPlayer: bool = false

var velocity: Vector2

var moveSpeed: int = ((64 / 2) * 3)
var gravity: int = 64*8
var jumpForce: int = ((64 / 2) * 5)

var jumpCounter: int = 2
var attackSpeed: float = 0.2

func movement() -> void:
	# Get movement direction and apply initial directional velocity value
	velocity.x = 0
	
	#var attack = Input.is_action_pressed("ui_up")
	velocity.x -= int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))
	
	# Set local player flip value
	if velocity.x < 0:
		$AnimatedSprite.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite.flip_h = false
	
	# apply speed velocity
	velocity.x *= moveSpeed

func flip(newValue) -> void:
	$AnimatedSprite.flip_h = newValue
	print($AnimatedSprite.flip_h)

func jump() -> void:
	# Reset counter
	if is_on_floor() and jumpCounter < 2:
		jumpCounter = 2
	
	# Jumping
	if Input.is_action_just_pressed('up') and jumpCounter > 0:
		jumpCounter -= 1
		velocity.y = -jumpForce + -64

func _physics_process(delta) -> void:
	if localPlayer:
		# Apply gravity force
		velocity.y += gravity * delta
			
		# Get input
		movement()
		# move_and_slide() automatically includes the timestep in its calculation, so you should not multiply the velocity vector by delta.
		# specified -Y as UP
		velocity = move_and_slide(velocity, Vector2(0, -1))
		#attack()
		jump()
		#
		#setAnimation()
		sendPosition()

func sendPosition() -> void:
	# Only send on movement
	if velocity.x != 0 or velocity.y != 0:
		Client.clientData.network.func = "clientPos"
		Client.clientData.movement.x = position.x
		Client.clientData.movement.y = position.y
		# Different type of data that may want to be sent elsewhere
		playerDataToSend()
		Client.send()

func playerDataToSend() -> void:
	Client.clientData.movement.anim = "name"
	Client.clientData.movement.flipH = $AnimatedSprite.flip_h
