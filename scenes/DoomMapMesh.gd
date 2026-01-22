class_name DoomMapMesh
extends MeshInstance3D


func _ready():
	pass


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
