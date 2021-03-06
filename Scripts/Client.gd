extends Node

signal clientConnect
signal spawnPlayers
signal syncPlayers

var serverData: Dictionary

var clientData: Dictionary = {
	"network": {
		"func": "methodName",
		"data": "dataToSend"
	},
	"movement": {
		"x": 0,
		"y": 0,
		"anim": "nameHere",
		"flipH": false,
		"attacking": false
	},
	"id": "clientIDHere"
}

# The URL we will connect to
export var websocket_url = "ws://localhost:9090"

# Our WebSocketClient instance
onready var _client: WebSocketClient = WebSocketClient.new()

func _ready() -> void:
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

func _closed(was_clean = false) -> void:
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = "") -> void:
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data() -> void:
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	#print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())
	serverData = _client.get_peer(1).get_var()
	clientConnect()
	spawnPlayers()
	syncPlayers()

func _process(delta) -> void:
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

# Opens the connection to the server
func openConnection() -> void:
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func send() -> void:
	_client.get_peer(1).put_var(clientData)

# Happens when this client connects to the server. Setups everything related to local client
func clientConnect() -> void:
	if serverData.network.func == "clientConnect":
		clientData.id = serverData.network.data
		emit_signal("clientConnect")
		print("clientConnect")

func spawnPlayers() -> void:
	if serverData.network.func == "spawnPlayers":
		emit_signal("spawnPlayers")
		print("spawnPlayers")

func syncPlayers() -> void:
	emit_signal("syncPlayers")
