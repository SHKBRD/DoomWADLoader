class_name DoomWADLoader
extends Node

class Lump: 
	var data: PackedByteArray

class DirectoryEntry:
	var offset: int
	var size: int
	var name: String

static var levelLumpNames: PackedStringArray = [
	"THINGS",
	"LINEDEFS",
	"SIDEDEFS",
	"VERTEXES",
	"SEGS",
	"SSECTORS",
	"NODES",
	"REJECT",
	"BLOCKMAP"
]

static var wadFile: FileAccess

static var signature: String
static var directory: Array[DirectoryEntry]

static var mapData: Array[RawDoomMap]

static func load_wad_from_disk(path: String = "") -> bool:
	if path == "":
		path = Globals.wadPath
	wadFile = FileAccess.open(path,FileAccess.READ)
	if wadFile == null:
		print(FileAccess.get_open_error())
		return false
	else:
		print("loaded")
		return true

static func get_wad_signature() -> String:
	wadFile.seek(0)
	return wadFile.get_buffer(4).get_string_from_ascii()

static func get_directory_entry(fileOffset: int, lumpIndex: int) -> DirectoryEntry:
	wadFile.seek(fileOffset+lumpIndex*16)
	
	var newEntry: DirectoryEntry = DirectoryEntry.new()
	newEntry.offset = wadFile.get_32()
	newEntry.size = wadFile.get_32()
	newEntry.name = wadFile.get_buffer(8).get_string_from_ascii()
	
	return newEntry

static func get_wad_directory() -> Array[DirectoryEntry]:
	wadFile.seek(4)
	
	var lumpAmount: int = wadFile.get_32()
	var directoryOffset: int = wadFile.get_32()
	
	var directoryEntries: Array[DirectoryEntry]
	for lumpIndex: int in range(lumpAmount):
		var newEntry: DirectoryEntry = get_directory_entry(directoryOffset, lumpIndex)
		directoryEntries.append(newEntry)
	
	return directoryEntries

static func entry_same(e: DirectoryEntry, levelName: String) -> bool:
	return e.name==levelName

static func get_lump_data(offset: int, size: int) -> PackedByteArray:
	wadFile.seek(offset)
	return wadFile.get_buffer(size)

static func get_level_lumps(levelName: String) -> Array[PackedByteArray]:
	var levelLumps: Array[PackedByteArray] = []
	var levelNameLumpInd: int = directory.find_custom(entry_same.bind(levelName))
	var levelNameLump: DirectoryEntry = directory[levelNameLumpInd]
	print(levelNameLump.name + " : " + str(levelNameLump.offset) + " : " + str(levelNameLump.size))
	
	var lumpInd: int = 0
	while directory[levelNameLumpInd+lumpInd].name in levelLumpNames:
		var focusLump: DirectoryEntry = directory[levelNameLumpInd+lumpInd]
		levelLumps.append(get_lump_data(focusLump.offset, focusLump.size))
		lumpInd += 1
	
	return levelLumps

static func initialize_wad(path: String = "") -> void:
	load_wad_from_disk(path)
	signature = get_wad_signature()
	print(signature)
	directory = get_wad_directory()

static func get_all_lump_names() -> PackedStringArray:
	return PackedStringArray(directory.map(func(d: DirectoryEntry): return d.name))

static func get_all_marker_lump_inds() -> PackedInt32Array:
	var inds: PackedInt32Array = PackedInt32Array()
	for dirInd: int in directory.size():
		if directory[dirInd].size == 0:
			inds.append(dirInd)
	return inds

static func get_map(mapID: String) -> RawDoomMap:
	return RawDoomMap.map_from_lumps(mapID, get_level_lumps(mapID))

static func get_wad_map_names() -> PackedStringArray:
	var maps: PackedStringArray = []
	var allLumpNames: PackedStringArray = get_all_lump_names()
	
	for lumpInd: int in allLumpNames.size():
		# check for if there's a valid marker lump before this one
		if lumpInd<1 or directory[lumpInd-1].size != 0: continue
		
		# this is set to false if the following lumps don't line up with the valid map lump order
		var isPostLevelLump: bool = true
		for levelLumpNameInd: int in levelLumpNames.size():
			if allLumpNames[lumpInd+levelLumpNameInd] != levelLumpNames[levelLumpNameInd]:
				isPostLevelLump = false
				break
		
		if isPostLevelLump:
			maps.append(allLumpNames[lumpInd-1])
	
	return maps
