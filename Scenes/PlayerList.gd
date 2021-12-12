extends Node2D

export(Resource) var playerScene

onready var _spawnPlayers = Client.connect("spawnPlayers", self, "spawn")
onready var _syncPlayers = Client.connect("syncPlayers", self, "syncEntities")

func spawn() -> void:
	var activePlayers: Array = get_children()
	var list: Array = Client.serverData.network.data

	# Spawn in appropriate networked player entitites
	for x in range(list.size()):
		var canSpawn: bool = true
		
		# Disallow activePlayers from being spawned again
		for y in range(activePlayers.size()):
			if activePlayers[y].name == list[x].id:
				canSpawn = false
		
		# Values that needs to update on player instances
		var player = playerScene.instance()
		player.name = list[x].id
		player.position.x = list[x].x
		player.position.y = list[x].y
		
		
		# Set clients player entity to localplayer
		if list[x].id == Client.clientData.id:
			player.localPlayer = true
		else: # Set networked player entities to different color
			player.modulate = Color.red
		
		if canSpawn:
			add_child(player)

func syncEntities() -> void:
	var activePlayers: Array = get_children()
	var list: Array = Client.serverData.movement.data
	if activePlayers.size() != 0:
		for x in range(activePlayers.size()):
			# Dont perform sync on local player
			if !activePlayers[x].localPlayer:
				# Position movement sync
				activePlayers[x].position.x = list[x].x
				activePlayers[x].position.y = list[x].y
				activePlayers[x].animSprite.play(list[x].anim)
				activePlayers[x].flip(list[x].flipH)
				activePlayers[x].attackFX(list[x].attacking)
			
			# Sync HP on all clients including local player
			activePlayers[x].health = list[x].hp
