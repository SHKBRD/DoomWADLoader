extends Node3D

@export var doomWAD: DoomWAD
@export var mapMesh: DoomMapMesh

func _ready() -> void:
	mapMesh.load_map(doomWAD.get_map("MAP01"))
