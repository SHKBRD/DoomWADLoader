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

func init_sector(rawSector: RawDoomMap.DoomSector, sectorId: int, sectorGeo: Array[PackedVector2Array]) -> void:
	ceilHeight = rawSector.ceilingHeight
	floorHeight = rawSector.floorHeight
	ceilTextureName = rawSector.ceilingTextureName
	floorTextureName = rawSector.floorTextureName
	lightLevel = rawSector.lightLevel
	build_sector_meshes(sectorGeo)

func add_polygon_to_ceil(tridPoly: PackedVector3Array) -> void:
	for polyPoint: Vector3 in tridPoly:
		polyPoint.y = ceilHeight
		ceilMesh.mesh.surface_set_normal(Vector3.DOWN)
		ceilMesh.mesh.surface_set_uv(Vector2.ZERO)
		ceilMesh.mesh.surface_add_vertex(polyPoint)

func add_polygon_to_floor(tridPoly: PackedVector3Array) -> void:
	for polyPoint: Vector3 in tridPoly:
		polyPoint.y = floorHeight
		floorMesh.mesh.surface_set_normal(Vector3.DOWN)
		floorMesh.mesh.surface_set_uv(Vector2.ZERO)
		floorMesh.mesh.surface_add_vertex(polyPoint)

func build_sector_meshes(sectorGeo: Array[PackedVector2Array]) -> void:
	ceilMesh.mesh.clear_surfaces()
	floorMesh.mesh.clear_surfaces()
	ceilMesh.mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for polygonPoints: PackedVector2Array in sectorGeo:
		var triangulatedPoly: Array[Vector2] = Array(Geometry2D.triangulate_polygon(polygonPoints)).map(func(i): return polygonPoints[i])
		var heightedPoly: PackedVector3Array = PackedVector3Array(triangulatedPoly.map(func(v): return Vector3(v.x, 0, v.y)))
		add_polygon_to_ceil(heightedPoly)
		add_polygon_to_floor(heightedPoly)
	ceilMesh.mesh.surface_end()
	floorMesh.mesh.surface_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
