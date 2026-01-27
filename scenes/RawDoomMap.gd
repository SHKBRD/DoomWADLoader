class_name RawDoomMap
extends Resource

class DoomThing:
	var x: int
	var y: int
	var angleDegrees: int
	var type: int
	var flags: int

class DoomLineDef:
	var v1: int
	var v2: int
	var flags: int
	var special: int
	var tag: int
	var sidenum1: int
	var sidenum2: int

class DoomSideDef:
	var xOff: int
	var yOff: int
	var upperTextureName: String
	var middleTextureName: String
	var lowerTextureName: String
	var sectorFace: int

class DoomSegment:
	var v1: int
	var v2: int
	var angleDegrees: int
	var lineDefInd: int
	var lineDefDirection: int
	var offset: int

class DoomSubsector:
	var segmentCount: int
	var segmentNumber: int
	
	func get_polygon(map: RawDoomMap) -> PackedVector2Array:
		if segmentCount == 1: return PackedVector2Array()
		var assemblePolygon: PackedVector2Array = PackedVector2Array()
		var testSeg: Array = []
		assemblePolygon.append(map.vertexes[map.segs[segmentNumber].v1])
		for i in range(segmentNumber, segmentNumber+segmentCount):
			var seg: DoomSegment = map.segs[i]
			testSeg.append([map.vertexes[seg.v1], map.vertexes[seg.v2]])
			assemblePolygon.append(map.vertexes[seg.v2])
		
		print(testSeg)
		return assemblePolygon

class DoomNode:
	var xPartitionStart: int
	var yPartitionStart: int
	var xPartitionChange: int
	var yPartitionChange: int
	var boundingBoxR: PackedByteArray
	var boundingBoxL: PackedByteArray
	var childRInd: int
	var childLInd: int

class DoomSector:
	var floorHeight: int
	var ceilingHeight: int
	var floorTextureName: String
	var ceilingTextureName: String
	var lightLevel: int
	var specialType: int
	var tagNumber: int
	var associatedLinedefs: Array[int]
	var associatedSubsectors

var name: String
var things: Array[DoomThing]
var lineDefs: Array[DoomLineDef]
var sideDefs: Array[DoomSideDef]
var vertexes: Array[Vector2i]
var segs: Array[DoomSegment]
var ssectors: Array[DoomSubsector]
var nodes: Array[DoomNode]
var sectors: Array[DoomSector]

static func make_things_from_lump(lump: PackedByteArray) -> Array[DoomThing]:
	var assemble: Array[DoomThing] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/10):
		var newObject := DoomThing.new()
		newObject.x = lumpStream.get_16()
		newObject.y = lumpStream.get_16()
		newObject.angleDegrees = lumpStream.get_16()
		newObject.type = lumpStream.get_16()
		newObject.flags = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func make_linedefs_from_lump(lump: PackedByteArray) -> Array[DoomLineDef]:
	var assemble: Array[DoomLineDef] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/14):
		var newObject := DoomLineDef.new()
		newObject.v1 = lumpStream.get_16()
		newObject.v2 = lumpStream.get_16()
		newObject.flags = lumpStream.get_16()
		newObject.special = lumpStream.get_16()
		newObject.tag = lumpStream.get_16()
		newObject.sidenum1 = lumpStream.get_16()
		newObject.sidenum2 = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble
	
static func make_sidedefs_from_lump(lump: PackedByteArray) -> Array[DoomSideDef]:
	var assemble: Array[DoomSideDef] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/30):
		var newObject := DoomSideDef.new()
		newObject.xOff = lumpStream.get_16()
		newObject.yOff = lumpStream.get_16()
		newObject.upperTextureName = lumpStream.get_data(8)[1].get_string_from_ascii()
		newObject.middleTextureName = lumpStream.get_data(8)[1].get_string_from_ascii()
		newObject.lowerTextureName = lumpStream.get_data(8)[1].get_string_from_ascii()
		newObject.sectorFace = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func make_vertexes_from_lump(lump: PackedByteArray) -> Array[Vector2i]:
	var assemble: Array[Vector2i] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/4):
		var newObject := Vector2i(lumpStream.get_16(), lumpStream.get_16())
		assemble.append(newObject)
	
	return assemble

static func make_segments_from_lump(lump: PackedByteArray) -> Array[DoomSegment]:
	var assemble: Array[DoomSegment] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/12):
		var newObject := DoomSegment.new()
		newObject.v1 = lumpStream.get_16()
		newObject.v2 = lumpStream.get_16()
		newObject.angleDegrees = lumpStream.get_16()
		newObject.lineDefInd = lumpStream.get_16()
		newObject.lineDefDirection = lumpStream.get_16()
		newObject.offset = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func make_ssectors_from_lump(lump: PackedByteArray) -> Array[DoomSubsector]:
	var assemble: Array[DoomSubsector] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/4):
		var newObject := DoomSubsector.new()
		newObject.segmentCount = lumpStream.get_16()
		newObject.segmentNumber = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func make_nodes_from_lump(lump: PackedByteArray) -> Array[DoomNode]:
	var assemble: Array[DoomNode] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/28):
		var newObject := DoomNode.new()
		newObject.xPartitionStart = lumpStream.get_16()
		newObject.yPartitionStart = lumpStream.get_16()
		newObject.xPartitionChange = lumpStream.get_16()
		newObject.yPartitionChange = lumpStream.get_16()
		newObject.boundingBoxR = lumpStream.get_data(8)[1]
		newObject.boundingBoxL = lumpStream.get_data(8)[1]
		newObject.childRInd = lumpStream.get_16()
		newObject.childLInd = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func make_sectors_from_lump(lump: PackedByteArray) -> Array[DoomSector]:
	var assemble: Array[DoomSector] = []
	var lumpStream: StreamPeerBuffer = StreamPeerBuffer.new()
	lumpStream.data_array = lump
	
	for _lumpObjectInd: int in range(lump.size()/26):
		var newObject := DoomSector.new()
		newObject.floorHeight = lumpStream.get_16()
		newObject.ceilingHeight = lumpStream.get_16()
		newObject.floorTextureName = lumpStream.get_data(8)[1].get_string_from_ascii()
		newObject.ceilingTextureName = lumpStream.get_data(8)[1].get_string_from_ascii()
		newObject.lightLevel = lumpStream.get_16()
		newObject.specialType = lumpStream.get_16()
		newObject.tagNumber = lumpStream.get_16()
		assemble.append(newObject)
	
	return assemble

static func insert_lump_data(map: RawDoomMap, lumps: Array[PackedByteArray]) -> void:
	map.things = make_things_from_lump(lumps[0])
	map.lineDefs = make_linedefs_from_lump(lumps[1])
	map.sideDefs = make_sidedefs_from_lump(lumps[2])
	map.vertexes = make_vertexes_from_lump(lumps[3])
	map.segs = make_segments_from_lump(lumps[4])
	map.ssectors = make_ssectors_from_lump(lumps[5])
	map.nodes = make_nodes_from_lump(lumps[6])
	map.sectors = make_sectors_from_lump(lumps[7])

static func post_insert_edits(map: RawDoomMap) -> void:
	link_sectors_to_linedefs(map)
	link_ssectors_to_sectors(map)

static func link_sectors_to_linedefs(map: RawDoomMap) -> void:
	for linedefInd: int in map.lineDefs.size():
		var linedef: DoomLineDef = map.lineDefs[linedefInd]
		
		var assocSector1: int = map.sideDefs[linedef.sidenum1].sectorFace
		var assocSector2: int = map.sideDefs[linedef.sidenum2].sectorFace
		if assocSector1 == assocSector2: continue
		#print(str(linedef.sidenum1) + " : " + str(linedef.sidenum2))
		var sector1: DoomSector = map.sectors[assocSector1]
		var sector2: DoomSector = map.sectors[assocSector2]
		
		if sector1.associatedLinedefs == null:
			sector1.associatedLinedefs = []
		if linedefInd not in sector1.associatedLinedefs and linedef.sidenum1 != -1:
			sector1.associatedLinedefs.append(linedefInd)
			#print(str(linedefInd) + " is paired with sector " + str(assocSector1))
		if sector2.associatedLinedefs == null:
			sector2.associatedLinedefs = []
		if linedefInd not in sector2.associatedLinedefs and linedef.sidenum2 != -1:
			sector2.associatedLinedefs.append(linedefInd)
			#print(str(linedefInd) + " is paired with sector " + str(assocSector2))

static func link_ssectors_to_sectors(map: RawDoomMap) -> void:
	for ssectorInd: int in map.ssectors.size():
		var ssector: DoomSubsector = map.ssectors[ssectorInd]
		
		var assocLinedef: DoomLineDef = map.lineDefs[map.segs[ssector.segmentNumber].lineDefInd]
		var assocSector: DoomSector
		if map.segs[ssector.segmentNumber].lineDefDirection == 0:
			assocSector = map.sectors[map.sideDefs[assocLinedef.sidenum1].sectorFace]
		else:
			assocSector = map.sectors[map.sideDefs[assocLinedef.sidenum2].sectorFace]
		
		if assocSector.associatedSubsectors == null:
			assocSector.associatedSubsectors = []
		assocSector.associatedSubsectors.append(ssectorInd)

static func map_from_lumps(mapName: String, lumps: Array[PackedByteArray]) -> RawDoomMap:
	var assembleMap: RawDoomMap = RawDoomMap.new()
	assembleMap.name = mapName
	
	insert_lump_data(assembleMap, lumps)
	post_insert_edits(assembleMap)
	
	return assembleMap
