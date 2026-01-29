class_name DoomSectorGeometry
extends Node3D

@onready var ceilMesh: MeshInstance3D = $CeilingMesh
@onready var floorMesh: MeshInstance3D = $FloorMesh
@onready var wallMesh: MeshInstance3D = $WallMesh
@export var testmat: StandardMaterial3D

var map: RawDoomMap
var sectorId: int

var ceilHeight: float
var floorHeight: float
var lightLevel: int

var ceilTextureName: String
var floorTextureName: String

var sectorPoints: PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ceilMesh.mesh = ArrayMesh.new()
	floorMesh.mesh = ArrayMesh.new()
	wallMesh.mesh = ArrayMesh.new()
	print(ceilMesh)
	print(ceilMesh.mesh)

func init_sector(map: RawDoomMap, rawSector: RawDoomMap.DoomSector, sectorId: int) -> void:
	self.map = map
	self.sectorId = sectorId
	ceilHeight = rawSector.ceilingHeight
	floorHeight = rawSector.floorHeight
	ceilTextureName = rawSector.ceilingTextureName
	floorTextureName = rawSector.floorTextureName
	lightLevel = rawSector.lightLevel
	build_sector_meshes(map)

func add_polygon_to_ceil(tridPoly: PackedVector3Array, surfArray: Array) -> void:
	if not Geometry2D.is_polygon_clockwise(Array(tridPoly).map(func(v): return Vector2(v.x, v.z))):
		tridPoly.reverse()
	for polyPoint: Vector3 in tridPoly:
		polyPoint.y = ceilHeight
		surfArray[Mesh.ARRAY_NORMAL].append(Vector3.DOWN)
		surfArray[Mesh.ARRAY_TEX_UV].append(Vector2.ZERO)
		surfArray[Mesh.ARRAY_VERTEX].append(polyPoint/100.0)

func add_polygon_to_floor(tridPoly: PackedVector3Array, surfArray: Array) -> void:
	if not Geometry2D.is_polygon_clockwise(Array(tridPoly).map(func(v): return Vector2(v.x, v.z))):
		tridPoly.reverse()
	var revPoly: PackedVector3Array = tridPoly.duplicate()
	revPoly.reverse()
	for polyPoint: Vector3 in revPoly:
		polyPoint.y = floorHeight
		surfArray[Mesh.ARRAY_NORMAL].append(Vector3.UP)
		surfArray[Mesh.ARRAY_TEX_UV].append(Vector2.ZERO)
		surfArray[Mesh.ARRAY_VERTEX].append(polyPoint/100.0)

func build_sector_meshes(map: RawDoomMap) -> void:
	ceilMesh.mesh.clear_surfaces()
	floorMesh.mesh.clear_surfaces()
	
	var ceilSurfaceArray: Array = []
	ceilSurfaceArray.resize(Mesh.ARRAY_MAX)
	ceilSurfaceArray[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	ceilSurfaceArray[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	ceilSurfaceArray[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	var floorSurfaceArray = ceilSurfaceArray.duplicate(true)
	
	var subsectors: Array = map.sectors[sectorId].associatedSubsectors
	
	print()
	print("Sector " + str(sectorId))
	for subsectorInd: int in subsectors:
		var subsector: RawDoomMap.DoomSubsector = map.ssectors[subsectorInd]
		var polygonPoints: PackedVector2Array = subsector.get_polygon(map)
		if polygonPoints.is_empty(): continue
		#zzz
		#if polygonPoints[0] != polygonPoints[polygonPoints.size()-1]:
			#print("ERR (" + str(subsectorInd) + "): " + str(polygonPoints))
		var triangulatedPoly: Array = Array(Geometry2D.triangulate_polygon(polygonPoints)).map(func(i): return polygonPoints[i])
		#print(triangulatedPoly)
		var heightedPoly: PackedVector3Array = PackedVector3Array(triangulatedPoly.map(func(v): return Vector3(v.x, 0, v.y)))
		add_polygon_to_ceil(heightedPoly, ceilSurfaceArray)
		add_polygon_to_floor(heightedPoly, floorSurfaceArray)
	
	ceilMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, ceilSurfaceArray)
	floorMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, floorSurfaceArray)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#build_sector_meshes(map)
