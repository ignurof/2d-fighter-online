extends Node2D

export(Resource) var playerScene

onready var _spawnPlayers = Client.connect("spawnPlayers", self, "spawn")
onready var _syncPlayers = Client.connect("syncPlayers", self, "syncEntities")

func spawn() -> void:
	var activePlayers: Array = get_children()
	var list: Array = Client.serverData.network.data
	# First remove activePlayers from list
	if activePlayers.size() != 0:
		for x in range(activePlayers.size()):
			if activePlayers[x].name == list[x].id:
				list[x] = null
	
	# Spawn in appropriate networked player entitites
	for x in range(list.size()):
		# Dont spawn the client as a networked entity
		if list[x].id == Client.clientData.id:
			return
		
		var player = playerScene.instance()
		player.name = list[x].id
		player.position.x = list[x].x
		player.position.y = list[x].y
		add_child(player)

func syncEntities() -> void:
	var activePlayers: Array = get_children()
	var list: Array = Client.serverData.movement.data
	if activePlayers.size() != 0:
		for x in range(activePlayers.size()):
			activePlayers[x].position.x = list[x].x
			activePlayers[x].position.y = list[x].y
