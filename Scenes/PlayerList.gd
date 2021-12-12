extends Node2D

export(Resource) var playerScene

onready var _spawnPlayers = Client.connect("spawnPlayers", self, "spawn")

func spawn() -> void:
	var activePlayers: Array = get_children()
	var list: Array = Client.serverData.network.data
	for x in range(list.size()):
		# Dont spawn the client as a networked entity
		if list[x].id == Client.clientData.id:
			return
		# Dont spawn the network entity if it already exists
		#TODO
		
		var player = playerScene.instance()
		player.name = list[x].id
		player.position.x = list[x].x
		player.position.y = list[x].y
