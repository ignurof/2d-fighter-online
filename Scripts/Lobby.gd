extends Control

onready var startBtn = $StartBtn

onready var _start = startBtn.connect("pressed", self, "start")
# Hides the lobby from view
onready var _begin = Client.connect("clientConnect", self, "hide")

func start() -> void:
	Client.openConnection()
