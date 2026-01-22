class_name DoomWAD
extends Node

var mapList: Array[String]

var columnAtlas: Dictionary
var imageAtlas: Dictionary

static func get_doom_wad(path: String = "") -> DoomWAD:
	DoomWADLoader.initialize_wad(path)
	var newWAD: DoomWAD = DoomWAD.new()
	
	newWAD.mapList = DoomWADLoader.get_wad_map_names()
	
	return newWAD
