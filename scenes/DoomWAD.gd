class_name DoomWAD
extends Node

class Lump: 
	var data: PackedByteArray

class DirectoryEntry:
	var offset: int
	var size: int
	var name: String

var file: FileAccess

var signature: String
var directory: Array[DirectoryEntry]

var mapData: Array[RawDoomMap]

func _ready() -> void:
	initialize_wad()

func load_wad_from_disk() -> bool:
	file = FileAccess.open(Globals.wadPath,FileAccess.READ)
	if file == null:
		print(FileAccess.get_open_error())
		return false
	else:
		print("loaded")
		return true

func get_wad_signature() -> String:
	file.seek(0)
	return file.get_buffer(4).get_string_from_ascii()

func get_directory_entry(fileOffset: int, lumpIndex: int) -> DirectoryEntry:
	file.seek(fileOffset+lumpIndex*16)
	
	var newEntry: DirectoryEntry = DirectoryEntry.new()
	newEntry.offset = file.get_32()
	newEntry.size = file.get_32()
	newEntry.name = file.get_buffer(8).get_string_from_ascii()
	
	return newEntry

func get_wad_directory() -> Array[DirectoryEntry]:
	file.seek(4)
	
	var lumpAmount: int = file.get_32()
	var directoryOffset: int = file.get_32()
	
	var directoryEntries: Array[DirectoryEntry]
	for lumpIndex: int in range(lumpAmount):
		var newEntry: DirectoryEntry = get_directory_entry(directoryOffset, lumpIndex)
		directoryEntries.append(newEntry)
	
	return directoryEntries

func entry_same(e: DirectoryEntry, levelName: String) -> bool:
	return e.name==levelName

func get_lump_data(offset: int, size: int) -> PackedByteArray:
	file.seek(offset)
	return file.get_buffer(size)

func get_level_lumps(levelName: String) -> Array[PackedByteArray]:
	var levelLumps: Array[PackedByteArray] = []
	var levelNameLumpInd: int = directory.find_custom(entry_same.bind(levelName))
	var levelNameLump: DirectoryEntry = directory[levelNameLumpInd]
	print(levelNameLump.name + " : " + str(levelNameLump.offset) + " : " + str(levelNameLump.size))
	
	for lumpInd: int in range(1, 12):
		var focusLump: DirectoryEntry = directory[levelNameLumpInd+lumpInd]
		levelLumps.append(get_lump_data(focusLump.offset, focusLump.size))
	
	return levelLumps

func initialize_wad() -> void:
	load_wad_from_disk()
	signature = get_wad_signature()
	print(signature)
	directory = get_wad_directory()

func get_map(mapID: String) -> RawDoomMap:
	return RawDoomMap.map_from_lumps(mapID, get_level_lumps(mapID))
