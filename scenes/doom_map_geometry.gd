class_name DoomMapGeometry
extends Node3D


@export var sectorList: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func get_separate_polygons(map: RawDoomMap, lineInds: Array[int]) -> Array[PackedInt32Array]:
	var lineList: Array[RawDoomMap.DoomLineDef] = []
	var manipLineInds: Array[int] = lineInds.duplicate()
	var separatePolygons: Array[PackedInt32Array] = []
	
	while not manipLineInds.is_empty():
		var makePolygon: PackedInt32Array = []
		var beginVertexInd: int = map.lineDefs[manipLineInds.pop_back()].v2
		var searchVertexInd: int = beginVertexInd
		
		var addPolygonInd: int = 0
		while addPolygonInd != -1:
			addPolygonInd = -1
			
			for manipLineIndInd: int in manipLineInds.size():
				var lineDef: RawDoomMap.DoomLineDef = map.lineDefs[manipLineInds[manipLineIndInd]]
				if lineDef.v1 == searchVertexInd:
					addPolygonInd = lineDef.v1
					manipLineInds.remove_at(manipLineIndInd)
					searchVertexInd = lineDef.v2
					break
				elif lineDef.v2 == searchVertexInd:
					addPolygonInd = lineDef.v2
					manipLineInds.remove_at(manipLineIndInd)
					searchVertexInd = lineDef.v1
					break
				
			
			if addPolygonInd != -1:
				makePolygon.append(addPolygonInd)
			elif addPolygonInd == -1:
				makePolygon.append(searchVertexInd)
				makePolygon.append(beginVertexInd)
				separatePolygons.append(makePolygon)
		
	return separatePolygons


func get_map_sector_vertices(map: RawDoomMap) -> Dictionary:
	var sectorsPolygons: Array[Array]
	var totalFloorVertexSize: int = 0
	
	for sectorInd: int in map.sectors.size():
		var sector: RawDoomMap.DoomSector = map.sectors[sectorInd]
		var sectorPolygons: Array[PackedInt32Array] = get_separate_polygons(map, sector.associatedLinedefs)
		var sectorPointedPolygons: Array[PackedVector2Array] = []
		for polygon: PackedInt32Array in sectorPolygons:
			
			var vectorPolygon: PackedVector2Array = []
			for pointInd: int in polygon:
				vectorPolygon.append(map.vertexes[pointInd])
			sectorPointedPolygons.append(vectorPolygon)
		
		var polygons: Array[PackedVector2Array] = []
		
		for polygon: PackedVector2Array in sectorPointedPolygons:
			polygons.append(PackedVector3Array())
			for point: Vector2 in polygon:
				var newVert: Vector2 = Vector2(point.x,-point.y)
				polygons[polygons.size()-1].append(newVert)
				totalFloorVertexSize += 1
		
		sectorsPolygons.append(polygons)
	
	return {
		"sectorsPolygons": sectorsPolygons,
		"totalFloorVertexSize" : totalFloorVertexSize
	}

func build_map_sectors(map: RawDoomMap) -> void:
	var sectorVerts: Dictionary = get_map_sector_vertices(map)
	var sectorsPolygons: Array = sectorVerts["sectorsPolygons"]
	for sectorInd: int in sectorsPolygons.size():
		var assembleSector: DoomSectorGeometry = DoomSectorGeometry.new()
		assembleSector.name = "Sector"+str(sectorInd)
		sectorList.add_child(assembleSector)
		assembleSector.init_sector(map.sectors[sectorInd], sectorInd, sectorsPolygons[sectorInd])

func initialize_geometry(map: RawDoomMap) -> void:
	build_map_sectors(map)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
