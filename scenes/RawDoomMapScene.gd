extends Node3D

var doomWAD: DoomWAD
@export var mapGeometry: DoomMapGeometry

func _ready() -> void:
	doomWAD = DoomWAD.get_doom_wad(Globals.wadPath)
	mapGeometry.initialize_geometry(doomWAD.get_map("E1M2"))
