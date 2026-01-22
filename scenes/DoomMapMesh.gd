class_name DoomMapMesh
extends MeshInstance3D


func _ready():
	pass

func get_separate_polygons(map: RawDoomMap, lineInds: Array[int]) -> Array[PackedInt32Array]:
	var lineList: Array[RawDoomMap.DoomLineDef] = []
	var manipLineInds: Array[int] = lineInds.duplicate()
	var separatePolygons: Array[PackedInt32Array] = []
	
	#for manipLineIndInd: int in manipLineInds.size():
		#var lineDef: RawDoomMap.DoomLineDef = map.lineDefs[manipLineInds[manipLineIndInd]]
		#print(str(manipLineIndInd) + " : " + str(lineDef.v1) + " : " + str(lineDef.v2))
	
	while not manipLineInds.is_empty():
		var makePolygon: PackedInt32Array = []
		var beginVertexInd: int = map.lineDefs[manipLineInds.pop_back()].v2
		var searchVertexInd: int = beginVertexInd
		
		var addPolygonInd: int = 0
		while addPolygonInd != -1:
			addPolygonInd = -1
			
			for manipLineIndInd: int in manipLineInds.size():
				var lineDef: RawDoomMap.DoomLineDef = map.lineDefs[manipLineInds[manipLineIndInd]]
				#print(str(searchVertexInd) + " : " + str(lineDef.v1) + " : " + str(lineDef.v2))
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
		if sectorInd == 30:
			pass
		var sector: RawDoomMap.DoomSector = map.sectors[sectorInd]
		var sectorPolygons: Array[PackedInt32Array] = get_separate_polygons(map, sector.associatedLinedefs)
		var sectorPointedPolygons: Array[PackedVector2Array] = []
		for polygon: PackedInt32Array in sectorPolygons:
			
			var vectorPolygon: PackedVector2Array = []
			for pointInd: int in polygon:
				vectorPolygon.append(map.vertexes[pointInd])
			sectorPointedPolygons.append(vectorPolygon)
		
		var ceilingPolygons: Array[PackedVector3Array] = []
		var floorPolygons: Array[PackedVector3Array] = []
		
		for polygon: PackedVector2Array in sectorPointedPolygons:
			ceilingPolygons.append(PackedVector3Array())
			floorPolygons.append(PackedVector3Array())
			for point: Vector2 in polygon:
				var newVert: Vector3 = Vector3(point.x,sector.ceilingHeight,-point.y)
				ceilingPolygons[ceilingPolygons.size()-1].append(newVert)
				var floorVert: Vector3 = Vector3(newVert)
				floorVert.y = sector.floorHeight
				floorPolygons[floorPolygons.size()-1].append(floorVert)
				totalFloorVertexSize += 1
			print(ceilingPolygons)
			print(floorPolygons)
			print()
		
		sectorsPolygons.append([ceilingPolygons, floorPolygons])
	
	return {
		"sectorsPolygons": sectorsPolygons,
		"totalFloorVertexSize" : totalFloorVertexSize
	}


func load_map(map: RawDoomMap) -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var sectorsPolygons: Array[Array] = []
	var totalFloorVertexSize: int = 0
	
	var vertexPackage: Dictionary = get_map_sector_vertices(map)
	sectorsPolygons = vertexPackage.sectorsPolygons
	totalFloorVertexSize = vertexPackage.totalFloorVertexSize
	
	
	for i in range(2):
		for sectorInd: int in sectorsPolygons.size():
			for polygonInd: int in sectorsPolygons[sectorInd][0].size():
				for pointInd: int in sectorsPolygons[sectorInd][0][polygonInd].size():
					var baseVert: Vector3 = sectorsPolygons[sectorInd][i][polygonInd][pointInd]
					verts.append(baseVert/100.0)
					normals.append(Vector3.UP*(i*-2+1))
					if i == (1):
						pass
					uvs.append(Vector2(i, i))
					#print(verts.size())
					#print(normals.size())
					
	
	var vertCount: int = 0
	for sectorInd: int in sectorsPolygons.size():
		for polygonInd: int in sectorsPolygons[sectorInd][0].size():
			var polygon3D: PackedVector3Array = sectorsPolygons[sectorInd][0][polygonInd]
			var polygon2D: PackedVector2Array = PackedVector2Array()
			for point: Vector3 in polygon3D:
				polygon2D.append(Vector2(point.x, point.z))
			var triInds: PackedInt32Array = Geometry2D.triangulate_polygon(polygon2D)
			#print(triInds)
			#print(totalFloorVertexSize)
			var ceilTriInds: Array = []
			for triInd: int in triInds.size():
				ceilTriInds.append(triInds[triInd]+vertCount)
			
			var vecCeilTriInds: Array = ceilTriInds.map(func(i): return verts[i])
			print(ceilTriInds)
			print(vecCeilTriInds)
			
			triInds.reverse()
			var floorTriInds: Array = []
			for triInd: int in triInds.size():
				floorTriInds.append(triInds[triInd]+vertCount+totalFloorVertexSize)
			
			var vecFloorTriInds: Array = floorTriInds.map(func(i): return verts[i])
			print(floorTriInds)
			print(vecFloorTriInds)
			
			indices.append_array(ceilTriInds)
			indices.append_array(floorTriInds)
			vertCount+= polygon3D.size()
			print()

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	#surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	print(totalFloorVertexSize)
	print(verts.size())
	print(uvs.size())
	print(normals.size())
	print(indices.size())
	
	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	ResourceSaver.save(mesh, "res://map.tres", ResourceSaver.FLAG_COMPRESS)
