class_name DoomSectorGeometry
extends Node3D

@export var ceilMesh: MeshInstance3D
@export var floorMesh: MeshInstance3D
@export var wallMesh: MeshInstance3D

var sectorId: int

var ceilHeight: float
var floorHeight: float
var lightLevel: int

var ceilTextureName: String
var floorTextureName: String

var sectorPoints: PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init_sector(map: RawDoomMap, rawSector: RawDoomMap.DoomSector, sectorId: int) -> void:
	self.sectorId = sectorId
	ceilHeight = rawSector.ceilingHeight
	floorHeight = rawSector.floorHeight
	ceilTextureName = rawSector.ceilingTextureName
	floorTextureName = rawSector.floorTextureName
	lightLevel = rawSector.lightLevel
	build_sector_meshes(map)

func add_polygon_to_ceil(tridPoly: PackedVector3Array) -> void:
	for polyPoint: Vector3 in tridPoly:
		polyPoint.y = ceilHeight
		ceilMesh.mesh.surface_set_normal(Vector3.DOWN)
		ceilMesh.mesh.surface_set_uv(Vector2.ZERO)
		ceilMesh.mesh.surface_add_vertex(polyPoint/100.0)

func add_polygon_to_floor(tridPoly: PackedVector3Array) -> void:
	var revPoly: PackedVector3Array = tridPoly.duplicate()
	revPoly.reverse()
	for polyPoint: Vector3 in revPoly:
		polyPoint.y = floorHeight
		floorMesh.mesh.surface_set_normal(Vector3.UP)
		floorMesh.mesh.surface_set_uv(Vector2.ZERO)
		floorMesh.mesh.surface_add_vertex(polyPoint/100.0)

func build_sector_meshes(map: RawDoomMap) -> void:
	ceilMesh.mesh.clear_surfaces()
	floorMesh.mesh.clear_surfaces()
	ceilMesh.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	floorMesh.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var subsectors: Array = map.sectors[sectorId].associatedSubsectors.map(func(i): return map.ssectors[i])
	
	print()
	print("Sector " + str(sectorId))
	for subsector: RawDoomMap.DoomSubsector in subsectors:
		var polygonPoints: PackedVector2Array = subsector.get_polygon(map)
		if polygonPoints.is_empty(): continue
		if polygonPoints[0] != polygonPoints[polygonPoints.size()-1]:
			print("ERR: " + str(polygonPoints))
		var triangulatedPoly: Array = Array(Geometry2D.triangulate_polygon(polygonPoints)).map(func(i): return polygonPoints[i])
		var heightedPoly: PackedVector3Array = PackedVector3Array(triangulatedPoly.map(func(v): return Vector3(v.x, 0, v.y)))
		add_polygon_to_ceil(heightedPoly)
		add_polygon_to_floor(heightedPoly)
	
	ceilMesh.mesh.surface_end()
	floorMesh.mesh.surface_end()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
