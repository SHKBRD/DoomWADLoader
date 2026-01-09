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

	for sector: RawDoomMap.DoomSector in map.sectors:
		var startSearchLinedefInd: int = sector.associatedLinedefs[0]
		var startSearchLinedef: RawDoomMap.DoomLineDef = map.lineDefs[startSearchLinedefInd]
		var startSearchVector: Vector2i = map.vertexes[startSearchLinedef.v2]
		var searchVector: Vector2i = startSearchVector
		for linedefInd: int in sector.associatedLinedefs:
			pass

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
