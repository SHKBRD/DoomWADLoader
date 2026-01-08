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
var lumps: Array[Lump]

func _ready() -> void:
	initialize_wad()

func load_wad() -> bool:
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
	print(lumpAmount)
	print(String.num_int64(directoryOffset, 16, true))
	
	var directoryEntries: Array[DirectoryEntry]
	for lumpIndex: int in range(lumpAmount):
		var newEntry: DirectoryEntry = get_directory_entry(directoryOffset, lumpIndex)
		if newEntry.size == 0:
			print(newEntry.name + " : " + str(newEntry.offset) + " : " + str(newEntry.size))
		directoryEntries.append(newEntry)
	
	return directoryEntries

func initialize_wad() -> void:
	load_wad()
	signature = get_wad_signature()
	print(signature)
	directory = get_wad_directory()
	
