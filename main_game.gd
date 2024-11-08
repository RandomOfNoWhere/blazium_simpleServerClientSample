extends Node3D

@export var serverIP = "127.0.0.1"
@export var serverPort = 1234
var peer

#@export var player_scene : PackedScene
@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://MainGame.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connection_success)
	multiplayer.connection_failed.connect(connection_failed)

#Client and server side
func player_connected(id):
	print("Player Connected "+ str(id))
	
#Client and server side
func player_disconnected(id):
	print("Player Disconnected "+ id)
	
#Client side only
func connection_success():
	print("Connected to server!")

#Client side only
func connection_failed():
	print("Failed to connect to server!")

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(serverPort)
	if error != OK:
		print("Failed to host due to error: "+ error)
		return
	#May not be the best for your game, you should research this
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Ready for players!")
	
	#peer.create_server(1234)
	#multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(add_player)
	#add_player()
	$CanvasLayer.hide()

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(serverIP, serverPort)
	#This must match the server side compression
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	$CanvasLayer.hide()
	
func _on_start_game_pressed():
	StartGame.rpc()
	
	
#	peer.create_client("127.0.0.1",1234)
#	multiplayer.multiplayer_peer = peer

#func add_player(id = 1):
	#
	#var player = player_scene.instantiate()
	#player.name = str(id)
	#call_deferred("add_child",player)
	#
#func exit_game(id):
	#multiplayer.peer_disconnected.connect(del_player)
	#del_player(id)
	#
#func del_player(id):
	#rpc("_del_player",id)
#
#@rpc("any_peer","call_local")
#func  _del_player_id(id):
	#get_node(str(id)).queue_free()
