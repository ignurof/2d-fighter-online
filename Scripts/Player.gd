extends KinematicBody2D

onready var animSprite = $AnimatedSprite
onready var attackSprite = $AttackSprite
onready var combatArea = $CombatArea

# This happens on layer 2
onready var _addTarget = combatArea.connect("body_entered", self, "addTarget")
onready var _removeTarget = combatArea.connect("body_exited", self, "removeTarget")
var targetBody: KinematicBody2D = null
var attacking: bool = false

var localPlayer: bool = false

var velocity: Vector2

var moveSpeed: int = ((64 / 2) * 3)
var gravity: int = 64*8
var jumpForce: int = ((64 / 2) * 5)

var jumpCounter: int = 2
var attackSpeed: float = 0.2
var health: int = 100

func addTarget(body) -> void:
	if body.name != Client.clientData.id:
		targetBody = body
		print("Target: ", targetBody)

func removeTarget(body) -> void:
	targetBody = null

func attack() -> void:
	if Input.is_action_just_pressed("attack") and !attacking:
		attackSprite.visible = true
		attackSprite.play("attack")
		attacking = true
		# Send the attack to server if there was a target
		if targetBody != null:
			print("target attacked!")
			Client.clientData.network.func = "attack"
			Client.clientData.network.data = targetBody.name
			Client.clientData.movement.attacking = true
			#playerDataToSend(animSprite.animation, animSprite.flip_h)
		else:
			print("missing target")
			Client.clientData.network.func = "attack"
			Client.clientData.network.data = "null"
			Client.clientData.movement.attacking = true
		
		# Send to server after values have been filled in conditionals
		Client.send()
		Client.clientData.movement.attacking = false
		# Wait until stopping attack
		yield(get_tree().create_timer(attackSpeed), "timeout")
		attackSprite.visible = false
		attackSprite.stop()
		attacking = false

func attackFX(attackValue) -> void:
	if attackValue:
		attackSprite.visible = true
		attackSprite.play("attack")
		# Wait until stopping attack
		yield(get_tree().create_timer(attackSpeed), "timeout")
		attackSprite.visible = false
		attackSprite.stop()

func movement() -> void:
	# Get movement direction and apply initial directional velocity value
	velocity.x = 0
	
	#var attack = Input.is_action_pressed("ui_up")
	velocity.x -= int(Input.is_action_pressed("left")) - int(Input.is_action_pressed("right"))
	
	# Set local player flip value
	if velocity.x < 0:
		animSprite.flip_h = true
	if velocity.x > 0:
		animSprite.flip_h = false
	
	# apply speed velocity
	velocity.x *= moveSpeed

func flip(newValue) -> void:
	animSprite.flip_h = newValue

func jump() -> void:
	# Reset counter
	if is_on_floor() and jumpCounter < 2:
		jumpCounter = 2
	
	# Jumping
	if Input.is_action_just_pressed('up') and jumpCounter > 0:
		jumpCounter -= 1
		velocity.y = -jumpForce + -64

func _process(delta) -> void:
	$HealthBar.rect_size.x = (health / 4)

func _physics_process(delta) -> void:
	if localPlayer:
		# Apply gravity force
		velocity.y += gravity * delta
			
		# Get input
		movement()
		# move_and_slide() automatically includes the timestep in its calculation, so you should not multiply the velocity vector by delta.
		# specified -Y as UP
		velocity = move_and_slide(velocity, Vector2(0, -1))
		attack()		
		jump()
		# Animations
		if velocity.x != 0:
			animSprite.play("walk")
		else:
			animSprite.play("idle")
		# Send to server
		sendPosition()

func sendPosition() -> void:
	# Only send on movement
	if velocity.x != 0 or velocity.y != 0:
		Client.clientData.network.func = "clientPos"
		Client.clientData.movement.x = position.x
		Client.clientData.movement.y = position.y
		# Different type of data that may want to be sent elsewhere
		playerDataToSend(animSprite.animation, animSprite.flip_h)
		Client.send()
	else: # Send idle back once if stopped moving
		if Client.clientData.movement.anim == "walk" and animSprite.animation == "idle":
			playerDataToSend("idle", animSprite.flip_h)
			Client.send()

func playerDataToSend(animValue, flipValue) -> void:
	Client.clientData.movement.anim = animValue
	Client.clientData.movement.flipH = flipValue
	Client.clientData.movement.attacking = attacking
