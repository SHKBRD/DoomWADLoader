extends Node3D

var doomWAD: DoomWAD
@export var mapMesh: DoomMapMesh

func _ready() -> void:
	doomWAD = DoomWAD.get_doom_wad(Globals.wadPath)
	mapMesh.load_map(doomWAD.get_map("E1M1"))
